#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${CD_BIN:-/tmp/oss-tools/venvs/changedetection/bin/changedetection.io}"
PORT="${CD_PORT:-15000}"
DATA="$HERE/data"
LOG="$HERE/results/changedetection-server.log"
mkdir -p "$DATA" "$(dirname "$LOG")"
# Only needed in environments where egress proxy makes public DNS look like a private IP.
# Do not enable this on a machine reachable from untrusted networks unless you understand the SSRF risk.
if [ "${CD_ALLOW_PRIVATE:-}" = "1" ]; then
  export ALLOW_IANA_RESTRICTED_ADDRESSES=true
fi
exec "$BIN" -h 127.0.0.1 -p "$PORT" -d "$DATA" -C -l INFO
