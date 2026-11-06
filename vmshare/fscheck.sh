#!/usr/bin/env bash
sudo -v || exit 1
h() { printf '\n== %s\n' "$1"; }
h "режим"; [ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
h "диски"; lsblk -f
h "корень"; findmnt -no SOURCE,FSTYPE,OPTIONS /
h "/boot"; if findmnt /boot >/dev/null 2>&1; then findmnt -no SOURCE,FSTYPE,OPTIONS /boot; else echo "часть корня"; fi
h "fstab"; grep -vE '^\s*(#|$)' /etc/fstab
h "mkinitcpio"; grep -E '^(MODULES|HOOKS|COMPRESSION)=' /etc/mkinitcpio.conf
h "GRUB"; grep -E '^(GRUB_THEME|GRUB_GFXMODE|GRUB_CMDLINE_LINUX|GRUB_TERMINAL)' /etc/default/grub
h "файлы /boot (S<1: сжат или разрежен)"; find /boot -maxdepth 1 -type f -printf '%S\t%s\t%p\n'
if [ "$(findmnt -no FSTYPE /)" = btrfs ]; then
  h "btrfs: подтома"; sudo btrfs subvolume list /
  h "btrfs: сжатие /boot"; sudo btrfs property get /boot compression 2>&1
fi
h "ключи pacman"; findmnt /etc/pacman.d/gnupg >/dev/null 2>&1 && echo "tmpfs поверх gnupg (плохо)" || echo "ok: gnupg не tmpfs"
sudo pacman-key --list-keys 2>&1 | sed -n '1,3p'
h "остатки установщика"; pacman -Q 2>/dev/null | grep -i calamares || echo "пакетов нет"
h "pacman -Sy"; sudo pacman -Sy 2>&1 | tail -2
