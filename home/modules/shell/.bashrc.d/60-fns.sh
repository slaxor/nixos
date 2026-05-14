if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
	echo "This script is meant to be sourced, not run directly."
	exit 1
fi

# if the deeplx server isn't running, start it
_ensure_deeplx() {
	if ! pgrep -f deeplx; then
		deeplx >/dev/null 2>&1 &
	fi
	sleep 1
}

tl8() {
	_ensure_deeplx
	data=$(printf '{"text":"%s","source_lang":"%s","target_lang":"%s"}' "${3}" "${1}" "${2}")
	url="http://localhost:1188/translate"
	curl -q -X POST --data "${data}" "${url}" | jq '.data, .alternatives'
}

esde() { tl8 "ES" "DE" "${1}"; }

dees() { tl8 "DE" "ES" "${1}"; }

pdfscan() {
	basedir="${HOME}/SaSy/scans"
	timestamp=$(date +%y%m%d_%H%M%s)
	name="${basedir}/${1:-scan_${timestamp}}"
	jpg="${name}.jpg"
	pdf="${name}.pdf"
	scanimage \
		--device-name="pixma:04A91912_43AF62" \
		--resolution=300 \
		--format=jpeg \
		--progress \
		-o "${jpg}"
	ocrmypdf \
		--rotate-pages \
		--rotate-pages-threshold=5 \
		"${jpg}" "${pdf}"
	masterpdfeditor5 "${pdf}"
}

docker-image-export() {
	local rootfs="rootfs"
	if [ -d "${rootfs}" ]; then
		echo "${rootfs} already exists"
		return 1
	fi
	mkdir "${rootfs}"
	docker export "$(docker create "${1}")" | tar -C "${rootfs}" -xvf -
}

docker_clean() {
	set -x
	CONTAINERS=$(docker ps -qf status=exited)
	[ -z "${CONTAINERS}" ] || (echo "${CONTAINERS}" | xargs docker rm)
	IMAGES=$(docker images -qf dangling=true)
	[ -z "${IMAGES}" ] || (echo "${IMAGES}" | xargs docker rmi)
	VOLUMES=$(docker volume ls -qf dangling=true)
	[ -z "${VOLUMES}" ] || (echo "${VOLUMES}" | xargs docker volume rm)
	set +x
}

docker_find() {
	sudo find "$(docker inspect "$(docker volume ls | awk '/local/{print $2}')" | jq --raw-output '.[].Mountpoint')" -iname "*${1}*"
}

mkcd() {
	mkdir -p "${1}"
	cd "${_}"
}

urldecode() {
	: "${*//+/ }"
	echo -e "${_//%/\\x}"
}

sock2net() {
	local port=${2:-4444}
	socat -d -d -d -lf /tmp/socat_"${port}.log" \
		"TCP-LISTEN:${port},reuseaddr,fork" \
		"UNIX-CLIENT:${1}"
}

serial2net() {
	local port=23000
	echo "connecting ${1} to ${HOSTNAME}:${port}"
	socat "${1}",b115200,raw,echo=0,crnl tcp-listen:${port}
}

net2serial() {
	local port=23000
	local dev=${HOME}/tmp/vmodem0
	echo "creating  ${dev} from ${1}:${port}"
	socat "tcp-connect:${1}:${port}" "PTY,link=${dev}"
}

usb_start() {
	USBDISK=$1
	qemu-system-x86_64 -virtfs local,path="${PWD}",mount_tag=host0,security_model=passthrough,id=host0 -device piix3-usb-uhci -drive id=my_usb_disk,file="${USBDISK}",if=none -device usb-storage,drive=my_usb_disk
}

get_google_fonts() {
	cd "${HOME}"/.fonts
	curl -v -L https://github.com/google/fonts/archive/master.tar.gz |
		tar xzv --one-top-level=google-fonts --strip-components=1
	fc-cache -fs >/dev/null
	mkfontscale "${PWD}"/google-fonts
	mkfontdir "${PWD}"/google-fonts
}

godrop() {
	go clean "${1}"
	rm -rf "$(go env GOPATH)/src/${1}"
}

mkgoprj() {
	local prjname="${1}"
	local srcname="${2:-${prjname}}"
	prjpath="$(go env GOPATH)/src/codeberg.org/slaxor/${prjname}" && local prjpath
	mkdir -p "${prjpath}"
	cd "${prjpath}"
	cat >"Makefile" <<__EOL__
.DEFAULT_GOAL := test

.PHONY: debug
debug:
	dlv test -v ./...

.PHONY: test
test:
	go test -v ./...

__EOL__

	cat >"${srcname}.go" <<__EOL__
package ${prjname}

func ${srcname}() error {
  return nil
}
__EOL__

	cat >"${srcname}_test.go" <<__EOL__
package ${prjname}

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

func Test_${srcname}(t *testing.T) {
  err := ${srcname}()
  assert.NoError(t, err)
}
__EOL__

	go mod init "codeberg.org/slaxor/${prjname}"
	go mod tidy
	git init
	git add .
	git commit -m "Initial commit"
	git remote add origin "git@codeberg.org/slaxor/${prjname}.git"
	# git push -u origin master
}

redebug() { perl -Mre=debugcolor -e "'$1'=~/$2/"; }

_replace() {
	grep -rlZ "$1" | while IFS= read -r -d '' i; do
		sed -i -e "s/${1}/${2}/g" "${i}"
	done
}

replace() {
	fd -t f -x sed -i -e "s/${1}/${2}/g" {}
	fd "$1" -x rename -v -a "$1" "$2" {}
}

vcsv() { column -s,\; -t --table-header-repeat "${1:-/dev/stdin}" | sed -e "1i ${1:-/dev/stdin}" | less -#2 -N -S; }

sshdelhost() { sed -i -e "${1}d" "${HOME}/.ssh/known_hosts"; }

uriencode() {
	if (($# == 0)); then
		read -r s
	else
		s=$1
	fi
	s="${s//'%'/%25}"
	s="${s//' '/%20}"
	s="${s//'"'/%22}"
	s="${s//'#'/%23}"
	s="${s//'$'/%24}"
	s="${s//'&'/%26}"
	s="${s//'+'/%2B}"
	s="${s//','/%2C}"
	s="${s//'/'/%2F}"
	s="${s//':'/%3A}"
	s="${s//';'/%3B}"
	s="${s//'='/%3D}"
	s="${s//'?'/%3F}"
	s="${s//'@'/%40}"
	s="${s//'['/%5B}"
	s="${s//']'/%5D}"
	printf %s "${s}"
}

uridecode() {
	if (($# == 0)); then
		read -r s
	else
		s=$1
	fi
	s="${s//%25/'%'}"
	s="${s//%20/' '}"
	s="${s//%22/'"'}"
	s="${s//%23/'#'}"
	s="${s//%24/'$'}"
	s="${s//%26/'&'}"
	s="${s//%2B/'+'}"
	s="${s//%2C/','}"
	s="${s//%2F/'/'}"
	s="${s//%3A/':'}"
	s="${s//%3B/';'}"
	s="${s//%3D/'='}"
	s="${s//%3F/'?'}"
	s="${s//%40/'@'}"
	s="${s//%5B/'['}"
	s="${s//%5D/']'}"
	printf %s "${s}"
}

mkgit_example() {
	mkdir git_example
	cd "${_}"
	git init
	echo "first" >master.txt
	git add .
	git commit -m "Add master.txt"
	git checkout -b feature1
	echo "second" >feature1.txt
	git add .
	git commit -m "Add feature1.txt"
	git checkout master
	git checkout -b feature2
	echo "third" >feature2.txt
	git add .
	git commit -m "Add feature2.txt"
	git checkout feature1
	echo "fourth" >>feature1.txt
	git add .
	git commit -m "Change feature1.txt"
	git checkout feature2
	echo "fifth" >>feature2.txt
	git add .
	git commit -m "Change feature2.txt"
	git checkout master
	echo "sixth" >>master.txt
	git add .
	git commit -m "Change master.txt"
}

writeimg() {
	infile="${1}"
	outfile="${2}"
	fsize=$(stat "${infile}" | awk '/Size: /{print $2}') || return 1
	sudo dd if="${infile}" of="${outfile}" bs=128k status=progress \
		conv=sync 2>&1 |
		awk -v fsize="${fsize}" '{printf "%i of %i", $1, $fsize}'
}

mywine() {
	rm "${HOME}/.wine"
	local dir="${HOME}/.local/share/wine/${1}"
	mkdir -p "${dir}"
	ln -s "${dir}" "${HOME}/.wine"
	env WINEPREFIX="${dir}" wine "${2}"
}

asciiflow() {
	local clonedir="${HOME}/github.com/lewish/asciiflow"
	if [ ! -d "${clonedir}" ]; then
		git clone https://github.com/lewish/asciiflow2.git "${clonedir}"
		cd "${_}"
		./compile.sh
		chmod a+x closure-compiler.jar
	fi
	(
		sleep 1
		xdg-open http://127.0.0.1:45311
	) &
	python3 -m http.server 45311 --bind 127.0.0.1
}

to() {
	local fifo="/tmp/${USER}_pipe"
	[ -e "${fifo}" ] || mkfifo "${fifo}"
	cat /dev/stdin >"${fifo}"
}

from() {
	local fifo="/tmp/${1}_pipe"
	cat "${fifo}"
}

startvm() {
	nvram=uefi_vars.bin
	if [ ! -e "${nvram}" ]; then
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
	"${@:2}"
	# -smb /usr/local/public
}

mkvm() {
	name="$1"
	diskfile="${name}_disk1.qcow2"
	size=${2:-4G}
	startfile="runme.sh"
	mkdir "${name}"
	cd "${_}"
	qemu-img create -f qcow2 "${diskfile}" "${size}"
	echo -e '#!/bin/sh' >${startfile}
	# echo -e $(declare -f startvm) >>${startfile}
	echo -e "startvm ${diskfile}" >>${startfile}
	chmod 755 ${startfile}
}

tunnel() {
	host=${1}
	serve=${2}
	listen=${3:-${host_port}}

	ssh "${host}" -L "${serve}:localhost:${listen}" -N
}

tmux_send_everywhere() {
	for t in $(tmux list-panes -a -F '#S:#I.#P'); do
		tmux send-keys -t "${t}" "$@"
	done
}

tmux_send_panes() {
	for t in $(tmux list-panes -F '#S:#I.#P'); do
		tmux send-keys -t "${t}" "$@"
	done
}

# gen_sscert() {
# pushd "${PWD}"
# local HOST=${1:-*}
# WORKDIR=self_signed_cert_$(hexdump -v -e '/1 "%02x"' -n 16 /dev/urandom) && local WORKDIR
# local SUBJ="/C=DE"
# SUBJ+="/ST=Hamburg"
# SUBJ+="/L=Hamburg"
# SUBJ+="/O=Microprojects GmbH"
# SUBJ+="/OU=Self-Signer"
# SUBJ+="/CN=${HOST}.microprojects.de"
# local KEY=self_signed_key.pem
# local CSR=self_signed_csr.pem
# local CRT=self_signed_crt.pem
# mkdir "${WORKDIR}"
# cd "${WORKDIR}"
# openssl genrsa -out "${KEY}" 4096
# openssl req -new -subj "${SUBJ}" -key "${KEY}" -out "${CSR}"
# openssl x509 -req -days 3650 -in "${CSR}" -signkey "${KEY}" -out "${CRT}"
# popd
# }

gen_sscert() {
	pushd "${PWD}"
	local host=${1:-*.microprojects.de}
	local prefix=self_signed
	workdir=${prefix}_cert_$(date +%Y%m%d%H%M%S) && local workdir
	local subj="/C=DE"
	subj+="/ST=Hamburg"
	subj+="/L=Hamburg"
	subj+="/O=Microprojects GmbH"
	subj+="/OU=Self-Signer"
	subj+="/CN=${host}"
	local cakey=${prefix}_cakey.pem
	local cacsr=${prefix}_cacsr.pem
	local cacrt=${prefix}_cacrt.pem
	local serial=${prefix}_cacrt.srl
	local key=${prefix}_key.pem
	local csr=${prefix}_csr.pem
	local crt=${prefix}_crt.pem
	mkdir "${workdir}"
	cd "${workdir}"
	openssl genrsa -out ${cakey} 4096
	openssl req -new -subj "${subj}" -key ${cakey} -out ${cacsr}
	openssl x509 -req -days 3650 -in ${cacsr} -signkey ${cakey} -out ${cacrt}
	echo -n "00" >${serial}
	openssl genrsa -out ${key} 4096
	openssl req -new -subj "${subj}" -key ${key} -out ${csr}
	openssl x509 -req -days 3650 -in ${csr} -signkey ${key} -out ${crt} -CA ${cacrt} -CAkey ${cakey}
	popd
}

add_sscert() {
	local host=${1:-*.microprojects.de}
	local prefix=${host/\*/wildcard}
	workdir="${prefix}_cert_$(date +%Y%m%d%H%M%S)" && local workdir
	local subj="/C=DE"
	subj+="/ST=Hamburg"
	subj+="/L=Hamburg"
	subj+="/O=Microprojects GmbH"
	subj+="/OU=Self-Signer"
	subj+="/CN=${host}"
	local cakey="*cakey.pem"
	local cacrt="*cacrt.pem"
	local serial="*.srl"
	if [ -f "${cakey}" ] && [ -f "${cacrt}" ] && [ -f "${serial}" ]; then
		local key="${prefix}_key.pem"
		local csr="${prefix}_csr.pem"
		local crt="${prefix}_crt.pem"

		openssl genrsa -out "${key}" 4096
		openssl req -new -subj "${subj}" -key "${key}" -out "${csr}"
		openssl x509 -req -days 3650 -in "${csr}" -signkey "${key}" -out "${crt}" -CA "${cacrt}" -CAkey "${cakey}"
	else
		echo "please go to the directory with ${cakey}, ${cacrt} and ${serial} in it"
	fi
}

tree2project() {
	local root
	local -a stack=()
	local -a files=()

	# Root lesen
	IFS= read -r root
	root="${root%/}"

	mkdir -p "${root}"
	cd "${root}" || return 1

	while IFS= read -r line; do
		# Leerzeilen ignorieren
		[[ -z ${line} ]] && continue
		local indent=${line%%[├└]*}
		local level=$((${#indent} / 4))
		local name="${line##*── }"
		stack=("${stack[@]:0:level}")
		if [[ ${name} == */ ]]; then
			name="${name%/}"
			stack+=("${name}")
			mkdir -p "${stack[*]// /\/}"
		else
			local dir="${stack[*]// /\/}"
			mkdir -p "${dir}"
			touch "${dir}/${name}"
			files+=("${dir}/${name}")
		fi
	done
	"${EDITOR-vim}" "${files[@]}"
}
