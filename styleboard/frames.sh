#!/bin/sh
# 把各风格 demo 的风格帧收进图鉴：styles/<slug>/demo/stills/styleframe.jpg → img/<slug>_0.jpg
# sh styleboard/frames.sh [slug]：给了 slug 只做这一个风格（新风格用这个，免得把所有卡片重新编码一遍）
cd "$(dirname "$0")"
ONLY="${1:-*}"
[ "$ONLY" = "*" ] || [ -f "../styles/$ONLY/demo/stills/styleframe.jpg" ] || { echo "frames.sh: no styles/$ONLY/demo/stills/styleframe.jpg" >&2; exit 1; }
OK=""; FAIL=0
for f in ../styles/$ONLY/demo/stills/styleframe.jpg; do
  s=$(basename "$(dirname "$(dirname "$(dirname "$f")")")")
  if ffmpeg -v error -y -i "$f" -vf scale=1280:-1 -q:v 3 "img/${s}_0.jpg"; then echo "$s"; OK="$OK $s"
  else echo "frames.sh: could not write img/${s}_0.jpg" >&2; FAIL=1; fi
done
OK="$OK" python3 - <<'PY'
import json, os
c = json.load(open('img/credits.json'))
for s in os.environ['OK'].split(): c[f'{s}_0.jpg'] = {'frame': True}
json.dump(c, open('img/credits.json', 'w'), ensure_ascii=False, indent=1)
PY
python3 build.py && exit $FAIL
