#!/usr/bin/env bash
set -euo pipefail
PORT="${MEMOS_PORT:-18081}"
BASE="http://127.0.0.1:${PORT}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
RES="$HERE/results"
mkdir -p "$RES"

echo "healthz: $(curl -sS "$BASE/healthz")"
USER="${MEMOS_TEST_USER:-tester}"
PASS="${MEMOS_TEST_PASSWORD:-}"
if [ -z "$PASS" ]; then
  PASS="$(python3 -c 'import secrets; print(secrets.token_urlsafe(18))')"
fi

code=$(curl -sS -o "$RES/create_user.body.json" -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\",\"displayName\":\"测试员\"}" \
  "$BASE/api/users")
echo "create_user HTTP $code"

# Correct 26.x sign-in shape
code=$(curl -sS -o "$RES/signin.body.json" -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d "{\"passwordCredentials\":{\"username\":\"$USER\",\"password\":\"$PASS\"}}" \
  "$BASE/api/auth/signin")
echo "signin HTTP $code"
TOKEN="$(python3 -c "import json; print(json.load(open('$RES/signin.body.json')).get('accessToken',''))")"
if [ -z "$TOKEN" ]; then
  echo "signin failed; body:" >&2
  cat "$RES/signin.body.json" >&2
  exit 1
fi

curl -sS -o "$RES/create_memo.body.json" -w "create_memo HTTP %{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"content":"# 开源工具实测笔记\n\n今天实测了 yt-dlp、Memos 和 changedetection.io。\n\n- 标签：#测试 #开源 #知识库\n","visibility":"PRIVATE"}' \
  "$BASE/api/memos"

curl -sS -o "$RES/search_positive.body.json" -w "search_positive HTTP %{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  "$BASE/api/memos?filter=content.contains(%22Memos%22)"

curl -sS -o "$RES/search_negative.body.json" -w "search_negative HTTP %{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  "$BASE/api/memos?filter=content.contains(%22XYZNOTFOUND12345%22)"

python3 - << PY
import json
from pathlib import Path
res=Path("$RES")
pos=json.loads((res/"search_positive.body.json").read_text())
neg=json.loads((res/"search_negative.body.json").read_text())
print("positive_count", len(pos.get("memos") or []))
print("negative_count", len(neg.get("memos") or []))
create=json.loads((res/"create_memo.body.json").read_text())
print("created", create.get("name"), "tags", create.get("tags"))
# redact token
p=res/"signin.body.json"
d=json.loads(p.read_text())
if d.get("accessToken"):
    t=d["accessToken"]
    d["accessToken"]=t[:16]+"...REDACTED..."+t[-8:]
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2))
PY
