#!/usr/bin/env python3
"""Export the VLC redesign from Figma's REST API with as few calls as possible.

Figma limits these endpoints to roughly 20 calls a month on free seats, so this
script batches everything and caches every response; re-running reuses the cache.

  1. GET /v1/files/:key            -> source/file.json (every node, fill, text style, effect)
  2. GET /v1/images/:key png       -> source/frames/<frame>.png (all top-level frames, batched)
  3. GET /v1/images/:key svg       -> source/icons/<icon>.svg  (every component in the Icon frame)

Token: ~/.config/vlc-redux/figma-token (a personal access token with "File content: read").
Usage: python3 -I redux/tools/figma-export.py [--max-calls N]
Output goes to redux/design/source/, which git ignores.
"""

import argparse
import json
import pathlib
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

FILE_KEY = "CAuJVJyM5yY7PnyQQK9X24"
ICON_FRAME = "42:356"
API = "https://api.figma.com/v1"
REPO = pathlib.Path(__file__).resolve().parents[2]
OUT = REPO / "redux" / "design" / "source"
TOKEN_FILE = pathlib.Path.home() / ".config" / "vlc-redux" / "figma-token"


class Budget:
    def __init__(self, limit):
        self.limit, self.used = limit, 0

    def spend(self, what):
        if self.used >= self.limit:
            sys.exit(f"stopping before {what}: --max-calls {self.limit} reached")
        self.used += 1
        print(f"[api call {self.used}/{self.limit}] {what}", file=sys.stderr)


def api_get(path, token, budget, what):
    budget.spend(what)
    req = urllib.request.Request(f"{API}{path}", headers={"X-Figma-Token": token})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        body = e.read().decode(errors="replace")[:300]
        sys.exit(f"Figma API {e.code} on {what}: {body}")


def download(url, dest):
    # Rendered images come from Figma's CDN, which doesn't count against the API limit.
    dest.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=120) as r:
                dest.write_bytes(r.read())
            return
        except OSError:
            time.sleep(2 * (attempt + 1))
    print(f"  failed to download {dest.name}", file=sys.stderr)


def slug(name):
    s = re.sub(r"[^A-Za-z0-9]+", "-", name).strip("-").lower()
    return s or "unnamed"


def render(ids_names, fmt, scale, subdir, token, budget, batch):
    """Render nodes in batches; skip ones already on disk."""
    todo = [(i, n) for i, n in ids_names if not (OUT / subdir / f"{n}.{fmt}").exists()]
    for start in range(0, len(todo), batch):
        chunk = todo[start:start + batch]
        query = urllib.parse.urlencode({"ids": ",".join(i for i, _ in chunk), "format": fmt, "scale": scale})
        res = api_get(f"/images/{FILE_KEY}?{query}", token, budget, f"render {len(chunk)} {subdir} as {fmt}")
        if res.get("err"):
            sys.exit(f"render error: {res['err']}")
        for node_id, name in chunk:
            url = res.get("images", {}).get(node_id)
            if url:
                download(url, OUT / subdir / f"{name}.{fmt}")
            else:
                print(f"  no render for {node_id} ({name})", file=sys.stderr)
    print(f"{subdir}: {len(ids_names)} total, {len(todo)} newly rendered", file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--max-calls", type=int, default=6, help="hard cap on API calls this run (default 6)")
    args = ap.parse_args()

    if not TOKEN_FILE.exists():
        sys.exit(f"missing token file {TOKEN_FILE}")
    token = TOKEN_FILE.read_text().strip()
    budget = Budget(args.max_calls)
    OUT.mkdir(parents=True, exist_ok=True)

    file_json = OUT / "file.json"
    if not file_json.exists():
        doc = api_get(f"/files/{FILE_KEY}", token, budget, "file document")
        file_json.write_text(json.dumps(doc))
    doc = json.loads(file_json.read_text())

    page = doc["document"]["children"][0]
    frames, icons, seen = [], [], set()
    for node in page["children"]:
        if node.get("type") not in ("FRAME", "COMPONENT", "COMPONENT_SET", "SECTION"):
            continue
        name = f"{slug(node['name'])}--{node['id'].replace(':', '-')}"
        frames.append((node["id"], name))
        if node["id"] == ICON_FRAME:
            for child in node.get("children", []):
                if child.get("type") in ("COMPONENT", "INSTANCE", "FRAME"):
                    n = slug(child["name"])
                    if n in seen:
                        n = f"{n}--{child['id'].replace(':', '-')}"
                    seen.add(n)
                    icons.append((child["id"], n))

    (OUT / "frames.json").write_text(json.dumps([{"id": i, "file": f"{n}.png"} for i, n in frames], indent=1))
    render(frames, "png", 1, "frames", token, budget, batch=50)
    render(icons, "svg", 1, "icons", token, budget, batch=200)
    print(f"done: {budget.used} API call(s) used this run", file=sys.stderr)


if __name__ == "__main__":
    main()
