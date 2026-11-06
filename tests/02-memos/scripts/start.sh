#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${MEMOS_BIN:-/tmp/oss-tools/memos/memos}"
PORT="${MEMOS_PORT:-18081}"
DATA="$HERE/data"
LOG="$HERE/results/memos-server.log"
mkdir -p "$DATA" "$(dirname "$LOG")"
exec "$BIN" --data "$DATA" --port "$PORT" --addr 127.0.0.1 --driver sqlite --log-level info
