startvm() {
	nvram=uefi_vars.bin
	if [ ! -e "${nvram}" ] ; then
		echo "\"${nvram}\" doesn't exist creating a default"
		cp -v /usr/share/ovmf/x64/OVMF_VARS.fd "${nvram}"
	fi
  qemu-system-x86_64 -M q35 -cpu host -enable-kvm -m 24G -smp 2 \
		-drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file="${nvram}" \
		-drive format=qcow2,media=disk,file="${1}" \
		-vga qxl -global qxl-vga.ram_size=134217728 \
		-global qxl-vga.vram_size=134217728 -global qxl-vga.vgamem_mb=32 \
		-net nic,model=virtio -net user,hostfwd=tcp::11022-:22 \
		-usbdevice tablet
		${@:2}
		# -smb /usr/local/public
}

mkvm() {
  name="$1"
  diskfile="${name}_disk1.qcow2"
	size=${2:-4G}
  startfile="runme.sh"
  mkdir "${name}"
  cd $_
  qemu-img create -f qcow2 ${diskfile} ${size}
	echo -e '#!/bin/sh' >${startfile}
	# echo -e $(declare -f startvm) >>${startfile}
	echo -e "startvm ${diskfile}" >>${startfile}
  chmod 755 ${startfile}
}
