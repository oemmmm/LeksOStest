#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/LeksOS"
PROFILE="$BASE/LeksPlay"
WORK="$BASE/work"
OUT="$BASE/out"
TMP="$BASE/tmp"

cleanup() {
  sudo rm -rf -- "$WORK" "$TMP"
}
trap cleanup EXIT

sudo rm -rf -- "$WORK"
mkdir -p "$OUT" "$TMP"

sudo pacman -Syu --needed archiso

export SOURCE_DATE_EPOCH=$(date +%s)

sudo env TMPDIR="$TMP" SOURCE_DATE_EPOCH="$SOURCE_DATE_EPOCH" \
  mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"

sudo chown -R "$USER":"$USER" "$OUT"

cd "$OUT"
for f in *.iso; do
  sha256sum "$f" > "$f.sha256"
done
