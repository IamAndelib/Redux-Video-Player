# Brief: reviewer (D26 QC, D28)

You review one milestone's changes before merge. Read-only: do not edit files, run builds or long commands
(`git diff`, `git show`, reading files and grep are fine).

**Input from the lead:** milestone ID, branch, the diff command (e.g. `git diff main...m/<ID>-<slug> -- <paths>`), what
the milestone is meant to do, and what was already verified.

**Look for real defects only:** correctness bugs, crash or hang paths, shell robustness that would actually bite (quoting,
`set -e` pitfalls, exit codes), tests that don't test what they claim or hide failures, project-rule breaks
(`CLAUDE.md` § Rules: tokens not magic values, new files listed in both build systems, no edits outside
`modules/gui/qt/` and `redux/` without a DECISIONS entry, control IDs never renumbered), and duplication. Verify each
finding against the code before reporting it.

**Report (under 400 words):** a list of findings, most severe first:
`F<n> · P<0-3> · <file>:<line> · <problem> · <concrete failure scenario> · <suggested fix>`.
Then "Verified OK" for what you checked and found sound. If nothing survives verification, say so.
