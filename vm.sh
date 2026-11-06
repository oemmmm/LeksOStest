#!/usr/bin/env bash
set -euo pipefail
D1="$HOME/leksos-test.qcow2"     # установленная система (GDM, Budgie, ext4)
D2="$HOME/leksos-test2.qcow2"    # диск для проверки файловых систем
ISO=$(ls -t "$HOME"/LeksOS/out/leksos-*.iso 2>/dev/null | head -1 || true)
OVMF=/usr/share/edk2/x64
OPTS=(-enable-kvm -cpu host -m 4G -smp 4 -vga virtio)

if [[ ${UEFI:-0} == 1 ]]; then
  [[ -f $HOME/leksos-ovmf-vars.fd ]] || cp "$OVMF/OVMF_VARS.4m.fd" "$HOME/leksos-ovmf-vars.fd"
  OPTS+=(-drive "if=pflash,format=raw,readonly=on,file=$OVMF/OVMF_CODE.4m.fd"
         -drive "if=pflash,format=raw,file=$HOME/leksos-ovmf-vars.fd")
fi

case "${1:-iso}" in
  iso)   exec qemu-system-x86_64 "${OPTS[@]}" -cdrom "$ISO" \
           -drive file="$D1",if=virtio,format=qcow2,index=0 \
           -drive file="$D2",if=virtio,format=qcow2,index=1 -boot d ;;
  disk)  exec qemu-system-x86_64 "${OPTS[@]}" \
           -drive file="$D1",if=virtio,format=qcow2,index=0 \
           -drive file="$D2",if=virtio,format=qcow2,index=1 -boot c ;;
  disk2) exec qemu-system-x86_64 "${OPTS[@]}" \
           -drive file="$D2",if=virtio,format=qcow2,index=0 \
           -drive file="$D1",if=virtio,format=qcow2,index=1 -boot c ;;
  new2)     qemu-img create -f qcow2 "$D2" 30G ;;
  backup1)  cp --reflink=auto "$D1" "$D1.bak" && echo "копия: $D1.bak" ;;
  restore1) cp --reflink=auto "$D1.bak" "$D1" ;;
  *) echo "режимы: iso | disk | disk2 | new2 | backup1 | restore1   (UEFI=1 для UEFI)"; exit 1 ;;
esac
