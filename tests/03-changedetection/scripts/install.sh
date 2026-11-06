#!/usr/bin/env bash
set -euo pipefail
ROOT="${OSS_TOOLS_ROOT:-/tmp/oss-tools}"
VENV="$ROOT/venvs/changedetection"
mkdir -p "$ROOT/venvs"
python3 -m venv "$VENV"
"$VENV/bin/pip" install -U pip wheel
"$VENV/bin/pip" install -U "changedetection.io==0.70.2"
"$VENV/bin/pip" show changedetection.io | head -5
echo "installed: $VENV/bin/changedetection.io"
