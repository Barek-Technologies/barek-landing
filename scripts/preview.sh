#!/usr/bin/env bash
# Screenshot a landing page at desktop and true phone width, and report
# horizontal overflow at phone width. Uses headless Chrome, nothing else.
#
#   preview.sh <url-or-html-file> [out-dir]      (default out-dir: ./preview)
#
# Headless Chrome won't make a window narrower than 500px, so the phone shot
# renders the page inside a 390px iframe. Overflow is measured for local
# files only (an http page in an iframe is cross-origin); for a dev server,
# look at the phone shot's right edge instead.
set -euo pipefail

target="${1:-}"
out="${2:-preview}"
if [[ -z "$target" ]]; then
  echo "usage: preview.sh <url-or-html-file> [out-dir]" >&2
  exit 64
fi

chrome="${CHROME:-}"
for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "$(command -v google-chrome 2>/dev/null || true)" \
         "$(command -v chromium 2>/dev/null || true)" \
         "$(command -v chromium-browser 2>/dev/null || true)"; do
  [[ -z "$chrome" && -n "$c" && -x "$c" ]] && chrome="$c"
done
[[ -n "$chrome" ]] || { echo "Chrome not found; set CHROME=/path/to/chrome" >&2; exit 1; }

if [[ -f "$target" ]]; then url="file://$(cd "$(dirname "$target")" && pwd)/$(basename "$target")"; else url="$target"; fi
mkdir -p "$out"
out="$(cd "$out" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

shot() { # name width height page
  "$chrome" --headless=new --disable-gpu --hide-scrollbars --allow-file-access-from-files \
    --user-data-dir="$work/profile" --virtual-time-budget=6000 \
    --window-size="$2,$3" --screenshot="$out/$1.png" "$4" >/dev/null 2>&1
}

shot desktop 1440 4000 "$url"

cat > "$work/phone.html" <<EOF
<!doctype html><meta charset="utf-8">
<style>html,body{margin:0;background:#888}iframe{display:block;width:390px;height:3900px;border:0;background:#fff}</style>
<iframe id="f" src="$url"></iframe>
<script>
f.onload=function(){try{var d=f.contentDocument.documentElement;
document.title='overflow='+(d.scrollWidth-390);}catch(e){document.title='overflow=unknown';}};
</script>
EOF
shot phone 500 3900 "file://$work/phone.html"

report=$("$chrome" --headless=new --disable-gpu --allow-file-access-from-files --user-data-dir="$work/profile" \
  --virtual-time-budget=6000 --window-size=500,900 --dump-dom "file://$work/phone.html" 2>/dev/null \
  | grep -o 'overflow=[^<]*' | head -1 || true)

echo "desktop: $out/desktop.png (1440 wide)"
echo "phone:   $out/phone.png (390 wide, left 390px of the image)"
case "$report" in
  overflow=0|overflow=-*) echo "phone overflow: none" ;;
  overflow=unknown|"") echo "phone overflow: not measurable for this URL; check the shot" ;;
  *) echo "phone overflow: ${report#overflow=}px wider than the screen. Find the element and fix it."; exit 2 ;;
esac
