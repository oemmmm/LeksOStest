#!/usr/bin/env bash
# совпадает ли пакет calamares-leksos в репо с исходниками files/
P=$(ls -t /home/sam/repo/x86_64/calamares-leksos-*.pkg.tar.zst | head -1)
F=/home/sam/calamares-leksos/files
echo "пакет: $P"
cd "$F" || exit 1
for f in settings.conf $(cd modules && ls | sed 's|^|modules/|'); do
  bsdtar -xOf "$P" "etc/calamares/$f" 2>/dev/null | cmp -s - "$f" || echo "отличается: $f"
done
echo готово
