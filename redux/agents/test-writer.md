# Brief: test writer (D23, D28, Q0.6)

You propose the QA cases for one milestone before (or while) it's built. Read-only: you write your proposal in the
report, and the lead adds the cases and tests.

**Input from the lead:** milestone ID and its file (scope, acceptance), the brief and scope IDs it cites, and which QA
layers exist (`redux/QA.md`).

**For each acceptance criterion, brief decision (P…, C3…) and scope item (K…) the milestone touches,** propose:
- **One case** in `redux/qa/cases/*.yaml` format (`redux/QA.md` § Test case format): ID, title, layer, milestone,
  sources, expected, check.
- **The check that proves it**, preferring an existing one:
  - a new L4 component test (`tst_<Widget>.qml`: states × themes)
  - an L5 flow (`redux/qa/e2e/test_*.py`)
  - an L6 region (`redux/qa/visual/regions/<scene>.json`)
  - an L3 C test for player-core rules
  - a hand check in `redux/EVALUATION.md` only for what a person must judge (sound, feel, looks on a real desktop)
- **The bug it would catch:** name the code change that would make it fail. If you can't name one, the case proves
  nothing.

**Report (under 400 words):** the proposed cases in YAML, then for each new test a 3–6 line sketch (what it drives and
asserts), then the gaps: anything in the acceptance no layer can check yet.
