#!/usr/bin/env bash
set -euo pipefail
ROOT="${OSS_TOOLS_ROOT:-/tmp/oss-tools}"
VENV="$ROOT/venvs/ytdlp"
mkdir -p "$ROOT/venvs"
python3 -m venv "$VENV"
"$VENV/bin/pip" install -U pip wheel
"$VENV/bin/pip" install -U "yt-dlp==2026.10.26"
"$VENV/bin/yt-dlp" --version
echo "installed: $VENV/bin/yt-dlp"
