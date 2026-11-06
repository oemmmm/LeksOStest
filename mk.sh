#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/LeksOS"
mkdir -p logs tmp
sudo rm -rf work out
sudo env TMPDIR="$HOME/LeksOS/tmp" mkarchiso -v -w "$HOME/LeksOS/work" -o "$HOME/LeksOS/out" "$HOME/LeksOS/LeksPlay" \
  2>&1 | tee "logs/build-$(date +%Y%m%d-%H%M%S).log"
paplay /usr/share/sounds/ocean/stereo/dialog-warning.oga
paplay /usr/share/sounds/ocean/stereo/dialog-warning.oga
paplay /usr/share/sounds/ocean/stereo/dialog-warning.oga
