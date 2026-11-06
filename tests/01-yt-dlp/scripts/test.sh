#!/usr/bin/env bash
set -euo pipefail
YTDLP="${YTDLP:-/tmp/oss-tools/venvs/ytdlp/bin/yt-dlp}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$HERE/results"
mkdir -p "$OUT"
"$YTDLP" --version | tee "$OUT/version.txt"

UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'

run() {
  local id="$1" url="$2"; shift 2
  echo "===== $id ====="
  if "$YTDLP" --skip-download --dump-json --no-progress --ignore-config \
      --js-runtimes node --user-agent "$UA" "$@" "$url" \
      > "$OUT/${id}.raw.stdout.txt" 2> "$OUT/${id}.stderr.txt"; then
    python3 - << PY
import json
from pathlib import Path
raw = Path("$OUT/${id}.raw.stdout.txt").read_text()
objs=[]
for line in raw.splitlines():
    line=line.strip()
    if line:
        try: objs.append(json.loads(line))
        except json.JSONDecodeError: pass
if not objs:
    objs=[json.loads(raw)]
obj=objs[0]
trimmed={
    "id": obj.get("id"),
    "extractor": obj.get("extractor") or obj.get("extractor_key"),
    "title": obj.get("title"),
    "uploader": obj.get("uploader") or obj.get("channel"),
    "duration": obj.get("duration"),
    "upload_date": obj.get("upload_date"),
    "webpage_url": obj.get("webpage_url"),
    "view_count": obj.get("view_count"),
    "description_preview": (obj.get("description") or "")[:250],
}
Path("$OUT/${id}.metadata.json").write_text(json.dumps(trimmed, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(trimmed, ensure_ascii=False, indent=2))
PY
    echo "OK $id"
  else
    echo "FAIL $id"
    tail -5 "$OUT/${id}.stderr.txt" || true
  fi
}

run archive_big_buck_bunny "https://archive.org/details/BigBuckBunny"
run youtube_me_at_the_zoo "https://www.youtube.com/watch?v=jNQXAC9IVRw"

# Anonymous Bilibili cookies (not a login)
curl -sS -c "$OUT/bilibili.anon.cookies.txt" -A "$UA" -o /dev/null "https://www.bilibili.com/" || true
run bilibili_av2_cookies "https://www.bilibili.com/video/av2" --cookies "$OUT/bilibili.anon.cookies.txt" --referer "https://www.bilibili.com/"
echo "done"
