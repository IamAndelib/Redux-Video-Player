"""Compare the screenshot scenes (build/shots/<scene>.png, redux/tools/shoot.sh) region by region (QA layer L6, Q0.4).

  python3 -I redux/qa/visual/compare.py [--update] [scene ...]      default: every scene with a regions file

Each scene's regions are in redux/qa/visual/regions/<scene>.json, in the shape of openQA's needles (os-autoinst; the
format idea only): areas of `"type": "match"` (the default) are compared, areas of `"type": "exclude"` (time labels,
anything that changes from run to run) are left out of every match area they overlap. Per match area:

- **Figma:** DSSIM to the scene's Figma frame (redux/design/source/frames/, git-ignored): how far the redesign still
  is from the design. A progress score, never a failure.
- **Baseline:** DSSIM to the committed crop in redux/qa/visual/baselines/<scene>/<area>.png: a regression when it's
  above the area's `threshold` (default below). `--update` writes the crops after an intended change.

Writes build/shots/report.html, appends `l6.<scene>.<area>` results to $QA_RESULTS when it's set, and exits 1 when a
region regressed. DSSIM comes from ImageMagick 7 (`compare -metric DSSIM -read-mask`): 0 is identical, and masked
pixels count neither way.
"""

import glob
import html
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
HERE = os.path.join(ROOT, "redux", "qa", "visual")
SHOTS = os.path.join(ROOT, "build", "shots")
WORK = os.path.join(SHOTS, "compare")
FRAMES = os.path.join(ROOT, "redux", "design", "source", "frames")
W, H = 1920, 1080
# Two runs of a scene give 0 (Q0.4); a few changed pixels of text in a region already give about 0.0004.
THRESHOLD = 0.0002


def magick(*args, ok=(0,)):
    """Run ImageMagick; any exit status not in `ok` is an error (never a silent pass on a missing image)."""
    result = subprocess.run(["magick", *args], capture_output=True, text=True)
    if result.returncode not in ok:
        raise RuntimeError(f"magick {args[0]}: {result.stderr.strip() or f'exit {result.returncode}'}")
    return result


def dssim(a, b, mask, diff):
    """DSSIM of two same-size images with the mask's black pixels left out, and a diff image."""
    # Given images of different sizes, `compare` searches for the smaller one inside the larger and can report a
    # perfect match: a region resized without --update must fail instead.
    sizes = [magick("identify", "-format", "%wx%h", image).stdout for image in (a, b)]
    if sizes[0] != sizes[1]:
        raise RuntimeError(f"sizes differ ({sizes[0]} vs {sizes[1]}); after changing a region, run with --update")
    result = magick("compare", "-metric", "DSSIM", "-read-mask", mask, a, b, diff, ok=(0, 1))   # 1: they differ
    found = re.search(r"\(([-0-9.e]+)\)", result.stderr)   # "<absolute> (<normalised>)"
    if not found:
        raise RuntimeError(f"magick compare: no score in {result.stderr.strip()!r}")
    return float(found[1])


def figma_frame(node, anchor):
    """The Figma frame scaled like a screenshot: full-window (16:9) frames to 1920x1080, smaller ones (dialogs) at
    their own size on a dark canvas, where the app puts them (`anchor`: center, or northwest for a window the session
    places at the origin). None when it isn't exported."""
    found = glob.glob(os.path.join(FRAMES, f"*--{node.replace(':', '-')}.png")) if node else []
    if not found:
        return None
    out = os.path.join(WORK, f"figma-{node.replace(':', '-')}.png")
    ratio = magick("identify", "-format", "%[fx:abs(w/h-16/9)<0.01]", found[0]).stdout
    if ratio == "1":
        magick(found[0], "-resize", f"{W}x{H}!", out)
    else:
        magick(found[0], "-background", "#111111", "-gravity", anchor, "-extent", f"{W}x{H}", out)
    return out


def crop(image, area, out):
    magick(image, "-crop", f"{area['width']}x{area['height']}+{area['xpos']}+{area['ypos']}", "+repage", out)
    return out


def mask(area, excludes, out):
    """White over the area, black over the parts of exclude areas inside it."""
    draw = []
    for ex in excludes:
        x0, y0 = max(ex["xpos"], area["xpos"]) - area["xpos"], max(ex["ypos"], area["ypos"]) - area["ypos"]
        x1 = min(ex["xpos"] + ex["width"], area["xpos"] + area["width"]) - area["xpos"] - 1
        y1 = min(ex["ypos"] + ex["height"], area["ypos"] + area["height"]) - area["ypos"] - 1
        if x0 <= x1 and y0 <= y1:
            draw += ["-draw", f"rectangle {x0},{y0} {x1},{y1}"]
    magick("-size", f"{area['width']}x{area['height']}", "xc:white", "-fill", "black", *draw, out)
    return out


def compare_scene(scene, update):
    spec = json.load(open(os.path.join(HERE, "regions", f"{scene}.json")))
    shot = os.path.join(SHOTS, f"{scene}.png")
    rows, results = [], []
    if not os.path.exists(shot):
        return [(f"l6.{scene}", "fail", f"no screenshot; run redux/tools/shoot.sh {scene}")], f"<h2>{scene}</h2><p>no screenshot</p>"
    try:
        figma = figma_frame(spec.get("figma"), spec.get("anchor", "center"))
        figma_note = "no Figma frame"
    except RuntimeError as error:   # the Figma score is progress only: a bad frame mustn't stop the regression check
        figma, figma_note = None, f"Figma frame unusable ({error})"
    areas = [a for a in spec["area"] if a.get("type", "match") == "match"]
    excludes = [a for a in spec["area"] if a.get("type") == "exclude"]
    for area in areas:
        name, prefix = area["name"], os.path.join(WORK, f"{scene}-{area['name']}")
        threshold = area.get("threshold", THRESHOLD)
        baseline = os.path.join(HERE, "baselines", scene, f"{name}.png")
        try:
            ours, m = crop(shot, area, f"{prefix}.png"), mask(area, excludes, f"{prefix}.mask.png")
            to_figma = (dssim(ours, crop(figma, area, f"{prefix}.figma.png"), m, f"{prefix}.figma-diff.png")
                        if figma else None)
            if update:
                os.makedirs(os.path.dirname(baseline), exist_ok=True)
                magick(ours, "-strip", "-define", "png:compression-level=9", baseline)
            if os.path.exists(baseline):
                to_base = dssim(ours, baseline, m, f"{prefix}.baseline-diff.png")
                status = "pass" if to_base <= threshold else "fail"
            else:
                to_base, status = None, "skip"
        except RuntimeError as error:   # e.g. a region resized without --update: a failure, never a silent pass
            results.append((f"l6.{scene}.{name}", "fail", f"comparison error: {error}"))
            rows.append(f"<tr><td><b>{html.escape(name)}</b><br><small>fail</small></td>"
                        f"<td colspan=4>{html.escape(str(error))}</td></tr>")
            continue
        figma_text = f"Figma {to_figma:.4f}" if to_figma is not None else figma_note
        base_text = f"baseline {to_base:.5f} (≤ {threshold})" if to_base is not None else "no baseline (--update)"
        results.append((f"l6.{scene}.{name}", status, f"{base_text}; {figma_text}"))
        cells = [f"<td><b>{html.escape(name)}</b><br><small>{status}</small></td>",
                 f"<td>{to_figma:.4f}</td>" if to_figma is not None else "<td>–</td>",
                 f"<td>{to_base:.5f}</td>" if to_base is not None else "<td>–</td>",
                 f'<td><img src="compare/{scene}-{name}.png"></td>',
                 f'<td><img src="compare/{scene}-{name}.figma.png"></td>' if figma else "<td></td>"]
        rows.append("<tr>" + "".join(cells) + "</tr>")
    section = (f"<h2>{html.escape(scene)}</h2><p>{html.escape(spec.get('what', ''))}"
               f"{' · Figma ' + spec['figma'] if spec.get('figma') else ''}</p>"
               "<table><tr><th>Region</th><th>DSSIM to Figma</th><th>DSSIM to baseline</th><th>Build</th>"
               "<th>Figma</th></tr>" + "".join(rows) + "</table>")
    return results, section


def main():
    args = sys.argv[1:]
    update = "--update" in args
    scenes = [a for a in args if a != "--update"] or sorted(
        os.path.basename(p)[:-5] for p in glob.glob(os.path.join(HERE, "regions", "*.json")))
    shutil.rmtree(WORK, ignore_errors=True)   # never compare a previous run's crops
    os.makedirs(WORK)
    results, sections = [], []
    for scene in scenes:
        found, section = compare_scene(scene, update)
        results += found
        sections.append(section)
    rev = subprocess.run(["git", "-C", ROOT, "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout
    with open(os.path.join(SHOTS, "report.html"), "w") as out:
        out.write("<!doctype html><meta charset=utf-8><title>Redux visual diff</title><style>"
                  "body{font:14px system-ui;background:#111;color:#ddd;margin:24px}td{vertical-align:top;padding:6px;"
                  "border-bottom:1px solid #333}img{max-width:560px;border:1px solid #333}</style>"
                  f"<h1>Redux Video Player: screens by region</h1><p>From {rev.strip()}. DSSIM: 0 is identical. "
                  "Figma: distance to the design (progress, not a failure). Baseline: regression against the "
                  "committed crops.</p>" + "".join(sections))
    if os.environ.get("QA_RESULTS"):
        with open(os.environ["QA_RESULTS"], "a") as out:
            out.writelines(f"{c}\t{s}\t{d}\n" for c, s, d in results)
    for check, status, detail in results:
        print(f"  {status}  {check}  ({detail})")
    print(f"  {os.path.join(SHOTS, 'report.html')}")
    return 1 if any(s == "fail" for _, s, _ in results) else 0


if __name__ == "__main__":
    sys.exit(main())
