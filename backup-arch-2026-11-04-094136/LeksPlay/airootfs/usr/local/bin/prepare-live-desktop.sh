#!/bin/sh

xdg=$(xdg-user-dir DESKTOP)
src='/usr/share/applications'

userid=$(id -u $USER)
if [ ! -d "/.Trash-$userid" ]; then
    sudo mkdir -p /.Trash-$userid/{expunged,files,info}
    sudo chown -R $userid /.Trash-$userid
fi

for f in $(ls $xdg/*desktop); do
    gio set -t string $f metadata::xfce-exe-checksum "$(sha256sum $f | awk '{print $1}')"
done;
