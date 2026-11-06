#!/usr/bin/env bash
set -euo pipefail
ROOT="${OSS_TOOLS_ROOT:-/tmp/oss-tools}"
DIR="$ROOT/memos"
VER="26.11.0"
URL="https://github.com/usememos/memos/releases/download/${VER}/memos_${VER}_linux_amd64.tar.gz"
SUM="38b81c2bd1859555f4f7f277756541fd1ca332c94bbbee443626ace42d7b4061"
mkdir -p "$DIR"
cd "$DIR"
curl -fsSL -o "memos_${VER}_linux_amd64.tar.gz" "$URL"
echo "${SUM}  memos_${VER}_linux_amd64.tar.gz" | sha256sum -c -
tar -xzf "memos_${VER}_linux_amd64.tar.gz"
chmod +x ./memos
./memos version || ./memos --version || true
echo "installed: $DIR/memos"
