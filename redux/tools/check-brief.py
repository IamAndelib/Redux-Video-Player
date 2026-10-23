#!/usr/bin/env python3
"""Check that redux/design/brief.md is complete and its references resolve.

    python3 -I redux/tools/check-brief.py [--draft]

Checks:
  1. every video link (?t=N) lies inside the video (duration from video-work/info.txt, else 21:00)
  2. every transcript section (except the sponsor) is cited by at least one video link in the brief
  3. every decision entry (a "- **" bullet under a lettered section) has a Refs line
  4. every frame file named in the brief comes from frame-picks.tsv, and every pick is used
  5. no placeholder text is left
  6. every decision entry starts with a unique ID of its section letter (`- **C3** · ...`); IDs are never
     renumbered: a new entry takes its section's next free number (QA test cases cite them, redux/QA.md)
--draft skips 4 and 5, for use before the frame analysis is done.
Exits 1 if any check fails.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DESIGN = ROOT / "redux/design"
PLACEHOLDER = "_Filled in from the frame analysis._"
DEFAULT_DURATION = 21 * 60  # the video runs 20:59.9


def frame_name(time, slug):
    minutes, _, seconds = time.partition(":")
    total = int(float(minutes) * 60 + float(seconds))
    return f"{total // 60:02d}{total % 60:02d}-{slug}.jpg"


def duration():
    info = DESIGN / "source/video-work/info.txt"
    if info.exists():
        match = re.search(r"^duration=([0-9.]+)", info.read_text(), re.M)
        if match:
            return float(match.group(1))
    return DEFAULT_DURATION


def main():
    draft = "--draft" in sys.argv[1:]
    brief = (DESIGN / "brief.md").read_text()
    transcript = (DESIGN / "transcript.md").read_text()
    errors = []

    times = [int(t) for t in re.findall(r"youtu\.be/ERFeOgqk324\?t=(\d+)", brief)]
    end = duration()
    errors += [f"video link t={t} is past the end ({end:.0f} s)" for t in times if t > end]

    sections = re.findall(r"^## (\d+)\. (.+?) \(\[\d+:\d+\]\(https://youtu\.be/ERFeOgqk324\?t=(\d+)\)\)$",
                          transcript, re.M)
    starts = [int(s[2]) for s in sections] + [int(end) + 1]
    for (number, title, start), stop in zip(sections, starts[1:]):
        if title == "Sponsor":
            continue
        if not any(int(start) <= t < stop for t in times):
            errors.append(f"transcript section {number} '{title}' is not cited in the brief")

    lettered = re.split(r"^## (?=[A-Z]\. )", brief, flags=re.M)[1:]
    ids = set()
    for section in lettered:
        heading = section.splitlines()[0]
        entries = re.split(r"^- \*\*", section, flags=re.M)[1:]
        for entry in entries:
            if "Refs:" not in entry:
                errors.append(f"entry without Refs in '{heading}': {entry.splitlines()[0][:60]}")
            match = re.match(r"([A-Z])(\d+)\*\* · ", entry)
            if not match or match.group(1) != heading[0]:
                errors.append(f"entry without a '{heading[0]}<n>' ID in '{heading}': {entry.splitlines()[0][:60]}")
            elif match.group(0) in ids:
                errors.append(f"duplicate ID {match.group(1)}{match.group(2)}")
            else:
                ids.add(match.group(0))

    if not draft:
        picks = {}
        picks_file = DESIGN / "frame-picks.tsv"
        for line in picks_file.read_text().splitlines():
            if not line.strip() or line.startswith("#"):
                continue
            cols = line.split("\t")
            picks[frame_name(cols[0], cols[1])] = cols
        used = set(re.findall(r"\b(\d{4}-[a-z0-9-]+\.jpg)\b", brief))
        errors += [f"brief names {f}, which frame-picks.tsv does not produce" for f in sorted(used - picks.keys())]
        errors += [f"pick {f} is not used in the brief" for f in sorted(picks.keys() - used)]
        if PLACEHOLDER in brief:
            errors.append("placeholder text is still in the brief")

    for error in errors:
        print(f"FAIL {error}")
    print(f"{len(times)} video links, {len(sections)} transcript sections, {len(lettered)} brief sections: "
          f"{'OK' if not errors else f'{len(errors)} problem(s)'}{' (draft mode)' if draft else ''}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
