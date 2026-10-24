# Agents: roles, hierarchy and briefs (D28)

Work is split between one **lead** and short-lived **specialist agents**. The lead is the main Claude session on a
milestone (or a human contributor); specialists are subagents the lead starts for one bounded job.

| Role | Who | Does | Never |
|---|---|---|---|
| **Lead** | main session / contributor | plans the milestone's tasks, writes the code, decides on every finding, runs QC, merges | delegates a decision or a merge |
| **Researcher** | subagent, [`researcher.md`](researcher.md) | finds prior art and upstream work for one question | edits files |
| **Reviewer** | subagent, [`reviewer.md`](reviewer.md) | reviews the milestone diff before merge (D26 QC) | edits files, runs builds |
| **QA triager** | subagent, [`qa-triager.md`](qa-triager.md) | reads a failing QA report and proposes causes | edits files |
| **QA expert** | subagent, [`qa-expert.md`](qa-expert.md) | judges a milestone's QA results through one rubric (visual, UX and accessibility, playback and formats, regressions) | edits files |
| **Test writer** | subagent, [`test-writer.md`](test-writer.md) | proposes cases and tests from the milestone's acceptance and the brief | edits files |

Rules:
1. **One bounded job per agent**, started with its brief from this folder plus the job's specifics (milestone ID,
   task IDs, files, question). Independent jobs run in parallel.
2. **Specialists report, the lead decides.** Every report uses IDs (`F1`, `F2` … for findings) and the P0–P3
   priorities below, so the lead can answer each one: fixed (commit), filed (issue), or rejected (reason).
3. **The QA loop** (generate, run, triage, fix, re-run; 3 rounds at most) is in [`../QA.md`](../QA.md#the-agent-loop-per-milestone-q06).
4. **The lead records the outcome** in the milestone file's Verification table (e.g. "review: F1 P1 fixed in
   `abc123`, F2 P3 filed #70").

## Priorities (findings, bugs, gaps; GitHub labels `priority:P0`…`P3`)
| Priority | Meaning | Rule |
|---|---|---|
| **P0** | crash, data loss, build or test suite broken, security | fix before anything else; blocks the merge |
| **P1** | wrong behaviour of an in-scope feature, a regression, a broken QA check | fix in this milestone; blocks the merge |
| **P2** | robustness, maintainability, a missing test, performance | fix now if small, else an issue for a named milestone |
| **P3** | polish, naming, nice-to-have | an issue, or rejected with a reason |
