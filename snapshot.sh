#!/usr/bin/env bash
# дерево файлов + содержимое текстовых файлов проекта в один файл
OUT=~/LeksOS/snapshot-$(date +%Y%m%d-%H%M).txt
MAX=30000                                    # не больше 30 КБ на файл
ROOTS=(~/LeksOS/LeksPlay ~/calamares-leksos)
EXCL=( -not -path '*/.git/*' -not -path '*/src/*' -not -path '*/pkg/*' \
       -not -path '*/wallpapers/*' -not -path '*/icons/*' \
       -not -name '*.pkg.tar.zst*' -not -name '*.iso' -not -name '*.qcow2' )
short() { echo "${1/#$HOME/~}"; }

# 1. отбор текстовых файлов (без секретов и бинарных)
mapfile -d '' ALL < <( { for r in "${ROOTS[@]}"; do find "$r" "${EXCL[@]}" -type f -size -${MAX}c -print0; done
  find ~/LeksOS -maxdepth 2 -type f \( -name '*.sh' -o -name '*.py' \) -size -${MAX}c -print0; } | sort -zu )
FILES=()
for f in "${ALL[@]}"; do
  case "${f##*/}" in shadow|gshadow|mirrorlist|*.gpg|*.key|*.pem|id_*) continue;; esac
  [ -s "$f" ] && grep -Iq '' "$f" 2>/dev/null && FILES+=("$f")
done
N=${#FILES[@]}

# 2. тело: каждый файл с рамкой-заголовком
BODY=$(mktemp); HEAD=$(mktemp); TOC=$(mktemp); i=0
for f in "${FILES[@]}"; do
  i=$((i+1))
  printf '\n\n################################################################\n' >> "$BODY"
  printf '#### ФАЙЛ %d/%d: %s  (%s байт, %s строк)\n' "$i" "$N" "$(short "$f")" "$(stat -c %s "$f")" "$(wc -l < "$f")" >> "$BODY"
  printf '################################################################\n' >> "$BODY"
  sed -E 's/\$(y|6|5|2[aby]?)\$[./A-Za-z0-9$]{8,}/<hash>/g' "$f" >> "$BODY"
  printf '\n#### конец файла: %s\n' "$(short "$f")" >> "$BODY"
done

# 3. шапка: версии, репо, дерево
{
echo "# snapshot $(date -Is)"
echo; echo "## версии"; pacman -Q pacman mkinitcpio archiso grub 2>&1
echo; echo "## репозиторий (локальный)"; ls -la ~/repo/x86_64 | grep -v '^total'
echo; echo "## [leksos] в базе"; pacman -Sl leksos 2>&1
echo; echo "## дерево файлов (тип, размер, путь)"
for r in "${ROOTS[@]}"; do echo "### $r"; find "$r" "${EXCL[@]}" -printf '%y %8s %P\n' | sort -k3; done
echo "### ~/LeksOS (скрипты)"; find ~/LeksOS -maxdepth 2 -type f \( -name '*.sh' -o -name '*.py' \) -printf '%y %8s %P\n' | sort -k3
} > "$HEAD" 2>&1

# 4. оглавление с номерами строк в итоговом файле
mk_toc() {
  echo; echo "## оглавление: строка в этом файле -> файл"
  grep -n '^#### ФАЙЛ' "$BODY" | while IFS=: read -r ln rest; do
    printf '%7d  %s\n' $((ln + $1)) "${rest#\#\#\#\# }"
  done
  echo
}
h=$(wc -l < "$HEAD"); t=$(mk_toc 0 | wc -l)
mk_toc $((h + t)) > "$TOC"

cat "$HEAD" "$TOC" "$BODY" > "$OUT"
{ echo; echo "## пропущено: файлы больше $MAX байт"
  for r in "${ROOTS[@]}"; do find "$r" "${EXCL[@]}" -type f -size +${MAX}c -printf '%8s %P\n'; done; } >> "$OUT"
rm -f "$BODY" "$HEAD" "$TOC"
echo "готово: $OUT ($(du -h "$OUT" | cut -f1), файлов: $N)"
