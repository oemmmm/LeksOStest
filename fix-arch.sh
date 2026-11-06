#!/usr/bin/env bash
# применяет механические правки следов Arch (перед этим делает бэкап)
set -e
P=${P:-$HOME/LeksOS/LeksPlay}
E=${E:-$HOME/calamares-leksos}
F=$E/files
for d in "$P" "$F"; do [ -d "$d" ] || { echo "нет каталога $d"; exit 1; }; done

B=${B:-$HOME/LeksOS/backup-arch-$(date +%F-%H%M%S)}
mkdir -p "$B"
cp -a "$P" "$B/LeksPlay"
cp -a "$F" "$B/files"
echo "бэкап: $B"

# 1. меню ISO и внутренние id
sed -i 's/Arch Linux install/LeksOS install/; s/archlinux/leksos/g' "$P/grub/loopback.cfg" "$P/grub/grub.cfg"
sed -i 's/^\(DEFAULT\|LABEL\) arch$/\1 leksos/' "$P"/syslinux/archiso_sys*.cfg
# 2. папка на ISO
sed -i 's/^install_dir="arch"/install_dir="leksos"/' "$P/profiledef.sh"
# 3. issue и os-release
printf 'LeksOS \\r (\\l)\n\n' > "$P/airootfs/etc/issue"
mkdir -p "$P/airootfs/usr/lib"
cp "$P/airootfs/etc/os-release" "$P/airootfs/usr/lib/os-release"
# 4. NoExtract в оба pacman.conf
for c in "$P/pacman.conf" "$P/airootfs/etc/pacman.conf"; do
  grep -q '^NoExtract.*arch-release' "$c" || sed -i '/^\[options\]/a NoExtract = etc/arch-release etc/issue usr/lib/os-release' "$c"
done
# 5. leks-update, юнит, пакеты
sed -i -E 's/arch-update/leks-update/Ig; s/Arch Linux/LeksOS/g; s/Arch news/LeksOS news/g' "$P/airootfs/usr/bin/leks-update"
sed -i 's/Live Arch Environment/Live LeksOS Environment/' "$P/airootfs/etc/systemd/system/livecd-alsa-unmuter.service"
sed -i '/^archinstall$/d' "$P/packages.x86_64"
echo "готово. вручную остались: иконка leksos.svg, ALCI-скрипты и картинки alci*.png"
