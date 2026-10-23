#!/usr/bin/env bash
# Compare the screenshot scenes (redux/tools/shoot.sh) with their Figma frames and committed baselines, region by
# region, and write build/shots/report.html. The work is done by redux/qa/visual/compare.py (Q0.4, QA layer L6);
# regions per scene in redux/qa/visual/regions/<scene>.json. Run inside the dev container:
#
#   redux/dev.sh run redux/tools/compare.sh [--update] [scene...]     --update rewrites the baselines (intended change)
set -euo pipefail
cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
exec python3 -I redux/qa/visual/compare.py "$@"
