#!/usr/bin/env python3
"""Validate the QA test cases and write the QA report (redux/QA.md).

    python3 -I redux/qa/report.py <results.tsv> <report.md>

Reads redux/qa/cases/*.yaml and the check results that redux/tools/qa.sh collected ("<check>\t<pass|fail|skip>\t
<detail>" lines), and writes a Markdown report: checks per layer, failures, every case's status, and coverage of
the brief (P1-P9 and its decision IDs) and of SCOPE.md (K and X IDs). Exits 1 if a check failed, 2 if a case file
is invalid.
"""
import fnmatch
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
LAYERS = [f"L{n}" for n in range(1, 10)]
# Definition of Done items a case can cite (redux/milestones/ROADMAP.md § Definition of Done).
DOD = {"build-and-tests", "keyboard", "qml-clean", "tokens", "spacing", "status-log", "crops", "qa-green"}
FIELDS = {"id", "title", "layer", "milestone", "sources", "check", "expected", "steps", "figma", "frame"}


def read(path):
    return (ROOT / path).read_text()


def brief_items():
    """{id: (title, planned milestone)} for the principles (P1-P9) and the decision entries."""
    text = read("redux/design/brief.md")
    items = {}
    principles = text.split("## Principles", 1)[1].split("\n## ", 1)[0]
    for number, title in re.findall(r"^(\d+)\. \*\*(.+?)\*\*", principles, re.M):
        items[f"P{number}"] = (title.rstrip("."), "every milestone")
    for entry in re.split(r"^(?=- \*\*[A-J]\d+\*\* · )", text, flags=re.M)[1:]:
        match = re.match(r"- \*\*([A-J]\d+)\*\* · \*\*(.+?)\*\*", entry)
        if match:
            build = re.search(r"Build: (.+?)(?: · |$)", entry, re.M)
            items[match.group(1)] = (match.group(2).rstrip(".,"), build.group(1).strip() if build else "")
    return items


def scope_items():
    """{id: (feature, milestone)} for the kept (K) and cut (X) entries of SCOPE.md."""
    text = read("redux/SCOPE.md")
    items = {}
    for row in re.findall(r"^\| K\d+ \|.*\|$", text, re.M):
        kid, feature, _notes, milestone = [cell.strip() for cell in row.strip("|").split("|")]
        items[kid] = (feature, milestone)
    for xid, title in re.findall(r"^- \*\*(X\d+)\*\* · \*\*(.+?)\*\*", text, re.M):
        items[xid] = (title.rstrip(".,"), "cut: M0.6 build, M0.8 UI")
    return items


def load_cases(sources):
    cases, errors = [], []
    decisions = set(re.findall(r"^### (D\d+) ", read("redux/milestones/DECISIONS.md"), re.M))
    milestones = set(re.findall(r"^\| \*\*([MQ]\d+\.\d+)\*\* \|", read("redux/milestones/ROADMAP.md"), re.M))
    hand = set(re.findall(r"^- \*\*([MQ]\d+\.\d+-\d+) ·", read("redux/EVALUATION.md"), re.M))
    for path in sorted((ROOT / "redux/qa/cases").glob("*.yaml")):
        for case in yaml.safe_load(path.read_text()) or []:
            where = f"{path.name}: {case.get('id', '?')}"
            missing = {"id", "title", "layer", "milestone", "sources", "check"} - case.keys()
            errors += [f"{where}: missing '{f}'" for f in sorted(missing)]
            errors += [f"{where}: unknown field '{f}'" for f in sorted(case.keys() - FIELDS)]
            if case.get("layer") not in LAYERS:
                errors.append(f"{where}: layer must be one of L1-L9")
            if case.get("milestone") not in milestones:
                errors.append(f"{where}: milestone {case.get('milestone')} is not in ROADMAP.md")
            for source in case.get("sources") or []:
                kind, _, ref = str(source).partition(":")
                ok = {"brief": lambda r: r in sources["brief"], "scope": lambda r: r in sources["scope"],
                      "decision": lambda r: r in decisions, "accept": lambda r: r in milestones,
                      "dod": lambda r: r in DOD}.get(kind, lambda r: False)(ref)
                if not ok:
                    errors.append(f"{where}: unknown source '{source}'")
            check = str(case.get("check", ""))
            if check.startswith("manual:") and check[7:] not in hand:
                errors.append(f"{where}: {check} is not an item in redux/EVALUATION.md")
            case["file"] = path.name
            cases.append(case)
    ids = [c.get("id") for c in cases]
    errors += [f"duplicate case ID {i}" for i in sorted({i for i in ids if ids.count(i) > 1})]
    return cases, errors


def load_results(path):
    results = {}
    for line in Path(path).read_text().splitlines():
        check, status, *detail = line.split("\t")
        results[check] = (status, detail[0] if detail else "")
    return results


def case_status(case, results):
    check = str(case["check"])
    if check.startswith("manual:"):
        return "hand check", f"redux/EVALUATION.md {check[7:]}"
    matched = {k: v for k, v in results.items() if fnmatch.fnmatchcase(k, check)}
    if not matched:
        # The case's layer ran but nothing matches its check: a dead reference, which must not pass silently.
        if any(k.startswith(case["layer"].lower() + ".") for k in results):
            return "fail", f"no check matches {check}"
        return "not run", check
    statuses = [s for s, _ in matched.values()]
    if "fail" in statuses:
        failed = [k for k, (s, _) in matched.items() if s == "fail"]
        return "fail", ", ".join(failed[:3]) + (" …" if len(failed) > 3 else "")
    if all(s == "skip" for s in statuses):
        return "skip", check
    return "pass", f"{len(matched)} check(s)" if len(matched) > 1 else check


ICON = {"pass": "✅ pass", "fail": "❌ fail", "skip": "⏭ skip", "not run": "· not run", "hand check": "✋ hand check"}


def coverage(lines, title, items, cases, statuses):
    cited = {}
    for case in cases:
        for source in case.get("sources") or []:
            cited.setdefault(str(source).split(":", 1)[1], []).append(case["id"])
    covered = sum(1 for i in items if i in cited)
    lines += [f"### {title}: {covered} of {len(items)} covered", "",
              "| ID | Item | Planned in | Cases |", "|---|---|---|---|"]
    for item, (text, milestone) in items.items():
        refs = ", ".join(f"{c} ({statuses[c]})" for c in cited.get(item, [])) or "—"
        lines.append(f"| {item} | {text[:70]} | {milestone or '—'} | {refs} |")
    lines.append("")


def main():
    results_path, report_path = sys.argv[1:3]
    sources = {"brief": brief_items(), "scope": scope_items()}
    cases, errors = load_cases(sources)
    results = load_results(results_path)
    statuses = {c["id"]: case_status(c, results)[0] for c in cases}

    failed = {k: v for k, v in results.items() if v[0] == "fail"}
    failed.update({f"case {c['id']}": ("fail", case_status(c, results)[1]) for c in cases
                   if statuses[c["id"]] == "fail" and case_status(c, results)[1].startswith("no check matches")})
    lines = ["# QA report", ""]
    lines += [f"**{'FAIL' if failed or errors else 'PASS'}**: {len(results)} checks run, "
              f"{sum(1 for v in results.values() if v[0] == 'pass')} passed, {len(failed)} failed, "
              f"{sum(1 for v in results.values() if v[0] == 'skip')} skipped. {len(cases)} cases: "
              + ", ".join(f"{n} {s}" for s in ICON if (n := sum(1 for v in statuses.values() if v == s))) + ".", ""]
    if errors:
        lines += ["## Invalid case files", ""] + [f"- {e}" for e in errors] + [""]
    if failed:
        lines += ["## Failed checks", ""] + [f"- `{k}`: {d}" for k, (_, d) in sorted(failed.items())] + [""]

    lines += ["## Checks per layer", "", "| Layer | Pass | Fail | Skip |", "|---|---|---|---|"]
    for layer in LAYERS:
        mine = [s for k, (s, _) in results.items() if k.startswith(layer.lower() + ".")]
        if mine:
            lines.append(f"| {layer} | {mine.count('pass')} | {mine.count('fail')} | {mine.count('skip')} |")
    lines += ["", "## Cases", "", "| Case | Layer | Title | Status | Evidence |", "|---|---|---|---|---|"]
    for case in sorted(cases, key=lambda c: (c["layer"], c["id"])):
        status, evidence = case_status(case, results)
        lines.append(f"| {case['id']} | {case['layer']} | {case['title']} | {ICON[status]} | {evidence} |")
    lines += ["", "## Coverage", "",
              "Which brief and scope items have cases. Items planned in later milestones get their cases then.", ""]
    coverage(lines, "Design brief", sources["brief"], cases, statuses)
    coverage(lines, "Scope", sources["scope"], cases, statuses)
    lines += ["## All checks", "", "| Check | Result | Detail |", "|---|---|---|"]
    lines += [f"| `{k}` | {s} | {d} |" for k, (s, d) in sorted(results.items())]

    Path(report_path).write_text("\n".join(lines) + "\n")
    for error in errors:
        print(f"INVALID {error}")
    print(lines[2])
    return 2 if errors else 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
