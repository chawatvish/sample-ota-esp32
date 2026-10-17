#!/bin/sh
# Build the firmware project and publish it to this repo (manifest.json + firmware.bin).
# Usage: ./publish.sh [path-to-firmware-project]   (default: ../ESP32_CYD_Demo)
# Set PUSH=1 to also `git push`.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJ="${1:-$HERE/../ESP32_CYD_Demo}"
PIO="${PIO:-$HOME/.platformio/penv/bin/pio}"
BASE="https://raw.githubusercontent.com/chawatvish/sample-ota-esp32/main"

VER=$(sed -n 's/^#define FW_VERSION \([0-9][0-9]*\).*/\1/p' "$PROJ/include/version.h")
[ -n "$VER" ] || { echo "FW_VERSION not found in $PROJ/include/version.h"; exit 1; }

CUR=$(sed -n 's/.*"version": *\([0-9][0-9]*\).*/\1/p' "$HERE/manifest.json" 2>/dev/null || echo 0)
if [ "$VER" -le "${CUR:-0}" ]; then
  echo "FW_VERSION ($VER) is not higher than published version ($CUR). Bump it in version.h first."
  exit 1
fi

"$PIO" run -d "$PROJ" -e esp32dev
cp "$PROJ/.pio/build/esp32dev/firmware.bin" "$HERE/firmware.bin"
printf '{"version": %s, "url": "%s/firmware.bin"}\n' "$VER" "$BASE" > "$HERE/manifest.json"

cd "$HERE"
git add firmware.bin manifest.json
git commit -m "Release firmware v$VER"
[ "$PUSH" = "1" ] && git push origin main
echo "Published v$VER."
[ "$PUSH" = "1" ] || echo "Run 'git push origin main' to make it live."
