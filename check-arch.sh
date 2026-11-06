#!/usr/bin/env bash
# следы Arch и ALCI в проекте (ничего не меняет)
P=${P:-$HOME/LeksOS/LeksPlay}      # профиль образа
E=${E:-$HOME/calamares-leksos}     # пакет calamares-leksos
F=$E/files
for d in "$P" "$F"; do [ -d "$d" ] || { echo "нет каталога $d"; exit 1; }; done
ok=0; no=0

has()  { grep -qiE -- "$1" "$2" 2>/dev/null; }
sec()  { printf '\n\e[1m%s\e[0m\n' "$1"; }
chk()  { if eval "$2" >/dev/null 2>&1; then printf '  \e[32m+\e[0m %s\n' "$1"; ok=$((ok+1)); else printf '  \e[31m-\e[0m %s\n' "$1"; no=$((no+1)); fi; }

sec "Следы Arch (видно пользователю)"
chk "меню ISO: нигде нет «Arch Linux» (и id archlinux)"        '! grep -rqiE "arch ?linux" "$P/grub" "$P/syslinux" "$P/efiboot"'
chk "profiledef.sh: install_dir не «arch»"                      '! has "^install_dir=.?arch.?$" "$P/profiledef.sh"'
chk "свой /etc/issue (иначе TTY пишет Arch Linux)"              'has leksos "$P/airootfs/etc/issue"'
chk "свой /usr/lib/os-release"                                  'has "^ID=leksos" "$P/airootfs/usr/lib/os-release"'
chk "pacman.conf: NoExtract для arch-release, issue, os-release" 'has "^NoExtract.*arch-release" "$P/airootfs/etc/pacman.conf"'
chk "иконка для LOGO=leksos"                                    'compgen -G "$P/airootfs/usr/share/icons/*/*/apps/leksos.*" || compgen -G "$P/airootfs/usr/share/pixmaps/leksos.*"'
chk "leks-update без «Arch-Update» и новостей Arch"             '! has "arch-update|arch linux|arch news" "$P/airootfs/usr/bin/leks-update"'
chk "юниты systemd без «Arch»"                                  '! grep -rqiE "live arch|arch linux" "$P/airootfs/etc/systemd"'
chk "в packages.x86_64 нет archinstall"                         '! has "^archinstall$" "$P/packages.x86_64"'

sec "Следы чужих дистрибутивов (ALCI, ArcoLinux)"
chk "в профиле нет alci / arcolinux"                            '! grep -rqIiE "(^|[^a-z])alci([^a-z]|$)|arcolinux" "$P"'
chk "в брендинге Calamares нет alci"                            '! grep -rqIiE "(^|[^a-z])alci([^a-z]|$)" "$F/branding" && ! ls "$F/branding/default" | grep -qi alci'

printf '\nИтого: \e[32m%d есть\e[0m, \e[31m%d нет\e[0m\n' "$ok" "$no"
