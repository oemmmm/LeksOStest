#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="leksos"
iso_label="LEKSOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="LeksOS <https://t.me/LEKS_PLAY>"
iso_application="LeksOS Live/Rescue DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
## GRUB
bootmodes=('bios.syslinux' 'uefi.grub')
## systemd-boot
#bootmodes=('bios.syslinux' 'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/etc/polkit-1/rules.d"]="0:0:750"
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/sudoers.d/g_wheel"]="0:0:440"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/dmcheck"]="0:0:755"
  ["/usr/local/bin/alci-displaymanager-check"]="0:0:755"
  ["/usr/local/bin/alci-virtual-machine-check"]="0:0:755"
  ["/usr/local/bin/remove-nvidia"]="0:0:755"
  ["/usr/local/bin/prepare-live-desktop.sh"]="0:0:755"
  ["/usr/local/bin/nvidia-module-loader"]="0:0:755"
  ["/usr/local/bin/pkexec-wrapper"]="0:0:755"
  ["/usr/bin/fastfetch"]="0:0:755"
  ["/usr/bin/leks-update"]="0:0:755"
  ["/usr/bin/leksos-first-login"]="0:0:755"
  ["/etc/skel/Desktop/lekszon.desktop"]="0:0:755"
  ["/etc/skel/Desktop/leksos-installer.desktop"]="0:0:755"
  ["/usr/local/bin/leksos-fix-boot"]="0:0:755"
  ["/usr/share/libalpm/hooks/95-leksos-fix-boot.hook"]="0:0:644"
)
