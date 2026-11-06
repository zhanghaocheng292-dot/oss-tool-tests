#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
API="http://127.0.0.1:${CD_PORT:-15000}"
RES="$HERE/results"
FIX="$HERE/fixture"
mkdir -p "$RES"

# API key lives in the datastore JSON, not secret.txt
KEY="$(python3 - << PY
import json
from pathlib import Path
p=Path("$HERE/data/changedetection.json")
data=json.loads(p.read_text())
print(data["settings"]["application"]["api_access_token"])
PY
)"
AUTH=(-H "x-api-key: $KEY" -H "Content-Type: application/json")

echo "===== systeminfo ====="
curl -sS "${AUTH[@]}" -w "\nHTTP %{http_code}\n" "$API/api/v1/systeminfo"

# ensure fixture v1
cp "$FIX/sample-v1.html" "$FIX/sample.html"
if ! curl -sf -o /dev/null "http://127.0.0.1:18099/sample.html"; then
  python3 -m http.server 18099 --bind 127.0.0.1 --directory "$FIX" &
  echo $! > /tmp/oss-tools-fixture.pid
  sleep 0.5
fi

echo "===== add fixture watch ====="
curl -sS "${AUTH[@]}" -o "$RES/add_fixture.body.json" -w "HTTP %{http_code}\n" \
  -X POST "$API/api/v1/watch" \
  -d '{"url":"http://127.0.0.1:18099/sample.html","title":"local fixture price page"}'
UUID="$(python3 -c "import json; print(json.load(open('$RES/add_fixture.body.json'))['uuid'])")"
curl -sS "${AUTH[@]}" -w " recheck HTTP %{http_code}\n" "$API/api/v1/watch/${UUID}?recheck=1"
sleep 2
curl -sS "${AUTH[@]}" -o "$RES/fixture_watch_v1.json" "$API/api/v1/watch/${UUID}"

cp "$FIX/sample-v2.html" "$FIX/sample.html"
curl -sS "${AUTH[@]}" -w " recheck2 HTTP %{http_code}\n" "$API/api/v1/watch/${UUID}?recheck=1"
sleep 2
curl -sS "${AUTH[@]}" -o "$RES/fixture_watch_v2.json" "$API/api/v1/watch/${UUID}"
curl -sS "${AUTH[@]}" -o "$RES/fixture_history.json" "$API/api/v1/watch/${UUID}/history"
python3 - << PY
import json
from pathlib import Path
v1=json.loads(Path("$RES/fixture_watch_v1.json").read_text())
v2=json.loads(Path("$RES/fixture_watch_v2.json").read_text())
print("v1 md5", v1.get("previous_md5"), "changed", v1.get("last_changed"), "error", v1.get("last_error"))
print("v2 md5", v2.get("previous_md5"), "changed", v2.get("last_changed"), "error", v2.get("last_error"))
print("history", Path("$RES/fixture_history.json").read_text())
if v2.get("last_changed") and v2.get("previous_md5") != v1.get("previous_md5"):
    print("CHANGE_DETECTED")
else:
    print("NO_CHANGE")
PY
