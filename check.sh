#!/usr/bin/env bash
# что из задуманного уже есть в проекте (ничего не меняет)
P=~/LeksOS/LeksPlay            # профиль образа
E=~/calamares-leksos           # пакет calamares-leksos (вместе с конфигами)
R=~/repo/x86_64                # локальное репо
URL=https://repo.lekshuesos.online/leksos/x86_64
DB=$R/leksos.db.tar.zst
F=$E/files; M=$F/modules
ok=0; no=0

has()  { grep -qiE -- "$1" "$2" 2>/dev/null; }
indb() { bsdtar -tf "$DB" 2>/dev/null | grep -qE "^$1-[0-9]"; }
sec()  { printf '\n\e[1m%s\e[0m\n' "$1"; }
chk()  {
  if eval "$2" >/dev/null 2>&1; then printf '  \e[32m+\e[0m %s\n' "$1"; ok=$((ok+1))
  else printf '  \e[31m-\e[0m %s\n' "$1"; no=$((no+1)); fi
}

sec "Репозиторий (локальная база)"
for p in calamares-leksos ckbcomp mkinitcpio-openswap yay-bin localsend-bin; do chk "$p" "indb $p"; done
chk "старых calamares, cachyos-calamares и leksos-calamares в базе нет" '! indb calamares && ! indb cachyos-calamares && ! indb leksos-calamares'
indb pacman && echo "  i pacman (форк CachyOS) всё ещё в репо"

sec "Версия calamares-leksos: исходник -> локальное репо -> сервер"
SRV=$(curl -fsS --max-time 20 "$URL/leksos.db" 2>/dev/null | bsdtar -tf - 2>/dev/null)
ver_in() { sed -n "s/^$1-\([0-9].*\)\/\$/\1/p" | head -1; }
s="$(sed -n 's/^pkgver=//p' "$E/PKGBUILD")-$(sed -n 's/^pkgrel=//p' "$E/PKGBUILD")"
l=$(bsdtar -tf "$DB" 2>/dev/null | ver_in calamares-leksos); r=$(echo "$SRV" | ver_in calamares-leksos)
[ "$s" = "$l" ] && [ "$l" = "$r" ] && f='\e[32m+\e[0m' || f='\e[31m-\e[0m'
printf "  $f исходник %-9s репо %-9s сервер %s\n" "$s" "${l:--}" "${r:--}"

sec "Профиль образа"
for p in calamares-leksos limine yay-bin localsend-bin tesseract-data-eng tesseract-data-rus; do
  chk "packages.x86_64: $p" "has '^$p\$' $P/packages.x86_64"
done
chk "в packages.x86_64 нет calamares, cachyos-calamares и leksos-calamares" '! has "^((cachyos|leksos)-)?calamares$" "$P/packages.x86_64"'
chk "pacman.conf: Server для [leksos] прямо в файле" 'has "Server *= *https://repo.lekshuesos.online" "$P/pacman.conf"'
chk "тема GRUB: в меню ISO и в системе" '[ -f "$P/grub/themes/leksos/theme.txt" ] && [ -f "$P/airootfs/usr/share/grub/themes/leksos/theme.txt" ]'
chk "grub.cfg: тема и 1280x720" 'has "set theme=" "$P/grub/grub.cfg" && has "1280x720" "$P/grub/grub.cfg"'
chk "syslinux: splash.png и цвета" '[ -f "$P/syslinux/splash.png" ] && has "MENU COLOR sel.*9e9e9e" "$P/syslinux/archiso_head.cfg"'
chk "profiledef.sh: без лишних файлов, есть leksos-fix-boot" '! has "calamares-online|removeun" "$P/profiledef.sh" && has "leksos-fix-boot" "$P/profiledef.sh"'
chk "скрипт leksos-fix-boot на месте" '[ -f "$P/airootfs/usr/local/bin/leksos-fix-boot" ]'
chk "старые хуки и usr/local/share/leksos убраны" '! ls $P/airootfs/etc/pacman.d/hooks/leksos-*.hook && [ ! -d "$P/airootfs/usr/local/share/leksos" ]'
chk "обои: новый leksos-first-login (ждёт plasmashell)" 'has busctl "$P/airootfs/usr/bin/leksos-first-login"'
chk "панель: Konsole закреплён, Calamares нет" 'L=$(grep -h "^launchers=" "$P/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc"); echo "$L" | grep -q konsole && ! echo "$L" | grep -qi calamares'

sec "Конфиги установщика (files/ в calamares-leksos)"
chk "settings.conf: без alci и initramfs" '! has "alci|initramfs" "$F/settings.conf"'
chk "settings.conf: @leksos-шаги и cleanup" 'has "users@leksos" "$F/settings.conf" && has "packages@leksos" "$F/settings.conf" && has "removeuser@leksos" "$F/settings.conf" && has "shellprocess@cleanup" "$F/settings.conf"'
chk "before: pacman-key и pacman -Syy" 'has "pacman-key --init" "$M/shellprocess-leksos-before.conf" && has "pacman -Syy" "$M/shellprocess-leksos-before.conf"'
chk "cleanup: тема, разрешение GRUB, leksos-fix-boot" '( for k in GRUB_THEME GRUB_GFXMODE leksos-fix-boot; do has $k "$M/shellprocess-leksos-cleanup.conf" || exit 1; done )'
chk "cleanup: убирает ярлык установщика" 'has "installer.*desktop|calamares.*desktop" "$M/shellprocess-leksos-cleanup.conf"'
chk "cleanup: убирает sudo без пароля и polkit-правило" 'has "g_wheel" "$M/shellprocess-leksos-cleanup.conf" && has "nopasswd" "$M/shellprocess-leksos-cleanup.conf"'
chk "packages-leksos.conf: try_remove для calamares-leksos" 'has "try_remove" "$M/packages-leksos.conf" && has "calamares-leksos" "$M/packages-leksos.conf" && ! has "^\s*- leksos-calamares" "$M/packages-leksos.conf"'
chk "пикер загрузчика: grub, rEFInd, Limine" 'has "id: *.?grub" "$M/packagechooser-bootloader.conf" && has "id: *.?refind" "$M/packagechooser-bootloader.conf" && has "id: *.?limine" "$M/packagechooser-bootloader.conf"'
chk "пикеры DE и менеджера входа: mode required" 'has "^mode: *required" "$M/packagechooser-de.conf" && has "^mode: *required" "$M/packagechooser-displaymanager.conf"'
chk "netinstall: Plasma Login Manager и SLiM есть, группы Bootloader нет" 'has "Plasma Login Manager" "$M/netinstall-packages.conf" && has "SLiM" "$M/netinstall-packages.conf" && ! has "name: *.?Bootloader" "$M/netinstall-packages.conf"'
chk "брендинг: LeksOS, без ALCI, есть grub.png" '! has "(productName|shortProductName|versionedName|shortVersionedName):.*ALCI" "$F/branding/default/branding.desc" && has "bootloaderEntryName: *LeksOS" "$F/branding/default/branding.desc" && [ -f "$F/branding/default/images/bootloader/grub.png" ]'

sec "calamares-leksos (PKGBUILD)"
chk "конфиги из files/ вставляются в пакет" 'has "startdir/files" "$E/PKGBUILD"'
chk "GRUB по умолчанию (efiBootLoader: grub)" 'has "efiBootLoader:.*grub" "$E/PKGBUILD"'
chk "conflicts без cachyos, замены ядра и id загрузчика" '! has "^conflicts=.*cachyos" "$E/PKGBUILD" && has "vmlinuz-linux-cachyos" "$E/PKGBUILD" && has "efiBootloaderId" "$E/PKGBUILD"'
chk "bootloader.conf: refindKernelList и limineSplashLogo" 'has "refindKernelList" "$E/PKGBUILD" && has "limineSplashLogo" "$E/PKGBUILD"'

sec "Последний ISO"
ISO=$(ls -t ~/LeksOS/out/leksos-*.iso 2>/dev/null | head -1)
if [ -z "$ISO" ]; then echo "  ISO не найден"; else
  echo "  $ISO ($(date -r "$ISO" '+%F %R'))"
  LIST=$(bsdtar -tf "$ISO" 2>/dev/null)
  chk "в ISO есть тема GRUB (меню live, UEFI)" 'echo "$LIST" | grep -q "boot/grub/themes/leksos/theme.txt"'
  chk "в ISO есть splash.png для syslinux" 'echo "$LIST" | grep -q "syslinux/splash.png"'
  echo "  изменено после сборки (в этот ISO не попало):"
  find "$P" "$F" "$E/PKGBUILD" "$R" -type f -newer "$ISO" ! -name '*.old' 2>/dev/null | sed 's|^|    |' | head -25
fi

printf '\nИтого: \e[32m%d есть\e[0m, \e[31m%d нет\e[0m\n' "$ok" "$no"
