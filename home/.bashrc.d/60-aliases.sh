[ -x /usr/bin/lsd ] && alias ls='/usr/bin/lsd'
alias dmesg='sudo dmesg -HT'
alias qr='qrencode -l L -t ANSI256UTF8'
alias otrdecode='otrtool -x \
  -e $(gopass show Account/onlinetvrecorder.com login) \
  -p $(gopass show -o Account/onlinetvrecorder.com)'
alias aaxtomp3='AAXtoMP3 --authcode $(gopass show -f Account/amazon.de aaxkey)'
# alias g='grep --exclude-dir={log,.git,.bundle,tmp,node_modules} -RnHEa --max-count=1000  --color=yes'
alias g='rg --hidden --follow --smart-case'
alias httpserver='python3 -m http.server 8000 --bind 127.0.0.1'
alias rmswp='rm -vf ~/tmp/*.sw?'
alias md='marked --gfm --breaks --tables --smart-lists'
alias pkill='/usr/bin/pkill -ef'
alias locate='/usr/bin/plocate'
alias makeitmine='sudo chown -R ${USER}:${GROUPS} .'
# alias installsize='pacman -Qi $(pacman -Qq) | awk "/Installed Size/{sub(/B$/, \"\", \$5) ; print \$4 \$5}"|numfmt --from=iec-i --to=none --invalid=ignore|paste -sd+ - | bc|numfmt --to=iec-i --suffix=B'
alias 3tw='xdotool key --repeat $((3*6*24)) --repeat-delay 60000 Shift_R'
# requires https://github.com/junegunn/fzf wants https://github.com/jneen/rouge
alias browsefiles="fzf --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || \\
  (highlight -O ansi -l {} || rougify {}  || coderay {} || cat {}) 2> /dev/null | head -500'"
alias updatemirrorlist='curl '\''https://archlinux.org/mirrorlist/?country=NL&country=SE&protocol=https&ip_version=4&use_mirror_status=on'\''|awk '\''/^#Server/{print substr($0,2)}'\''|sudo tee /etc/pacman.d/mirrorlist'


alias timelog="tj -template '{{color .}}{{.I}} {{.DeltaSecs}} {{.Text}}{{reset}}' -scale GreenToRed -scale-linear -scale-fast 2s -scale-slow 8s"
alias timestamp='date +%Y%m%d%H%M%S'
alias playstdmidi='fluidsynth -ni --audio-driver=alsa -r 44100 /usr/share/soundfonts/FluidR3_GM.sf2 /usr/share/soundfonts/FluidR3_GS.sf2'
alias boott5l='while ! $(ping -4 -W 1 -c 1 boot.t5l.de >/dev/null 2>&1 ) ; do echo down ; done ; gopass show -f luks/crocodile.t5l.de |ssh boot.t5l.de'
alias sslconn='rlwrap -D2 openssl s_client -crlf -connect'
alias fixtty='stty sane ; echo -e "\033c" ; tput rs1'
alias build_linos='d="/home/user" docker run -e "BRANCH_NAME=lineage-15.1" -e "DEVICE_LIST=angler" -e "SIGN_BUILDS=true" -e "SIGNATURE_SPOOFING=restricted" -e "CUSTOM_PACKAGES=GmsCore GsfProxy FakeStore MozillaNlpBackend NominatimNlpBackend com.google.android.maps.jar FDroid FDroidPrivilegedExtension " -v "${d}/lineage:/srv/src"  -v "${d}/zips:/srv/zips" -v "${d}/logs:/srv/logs" -v "${d}/cache:/srv/ccache" -v "${d}/keys:/srv/keys" -v "${d}/manifests:/srv/local_manifests" lineageos4microg/docker-lineage-cicd'
alias synch6="rsync -acb --progress /run/media/slash/H6_SD ${HOME}/Recordings/"

alias brinc='awk "{c=\$1 ; m=2047; n=c+(m/10) ;if (n>m) { n=m } ; printf \"%i\", n }" /sys/class/backlight/intel_backlight/brightness>/sys/class/backlight/intel_backlight/brightness'
alias brdec='awk "{c=\$1 ; m=2047; n=c-(m/10) ;if (n<0) { n=0 } ; printf \"%i\", n }" /sys/class/backlight/intel_backlight/brightness>/sys/class/backlight/intel_backlight/brightness'
alias brset='echo $1>/sys/class/backlight/intel_backlight/brightness'
alias brget='cat /sys/class/backlight/intel_backlight/brightness'
alias jq='/usr/bin/gojq'

# kitty terminal aliases

alias kittydiff='kitty +kitten diff'
alias icat='kitty +kitten icat'

# EO kitty terminal aliases

archlinuxtosd() {
  local device="${2:-/dev/mmcblk0}"
  local image="${HOME}/myinstall/netboot/archlinux-2022.03.01-x86_64.iso"
  time sudo dd if=${image} of=${device} bs=1M oflag=sync status=progress
}

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
  if [ -d "${rootfs}" ]
  then
    echo "${rootfs} already exists"
    return 1
  fi
  mkdir "${rootfs}"
  docker export $(docker create "${1}") | tar -C "${rootfs}" -xvf -
}

mkcd() { mkdir -p "${1}" ; cd $_; }

urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

termfont() {
  f=$(fc-list | awk 'BEGIN{FS=": "; IGNORECASE=1} {printf "%s\n", $2}'| \
    fzf --color=light --history=${HOME}/tmp/termfont_history)
  if ! [ -z "${f}" ]
  then
    echo "setting font to \"${f}\""
    printf '\e]50;xft:%s\007:size=12' "${f}"
  fi
}

sock2net() {
  local port=${2:-4444}
  socat -d -d -d -lf /tmp/socat_${port}.log \
    TCP-LISTEN:${port},reuseaddr,fork \
    UNIX-CLIENT:${1}
}

serial2net() {
  local port=23000
  echo "connecting ${1} to ${HOSTNAME}:${port}"
  socat "${1}",b115200,raw,echo=0,crnl tcp-listen:${port}
}

net2serial() {
  local port=23000
  local dev=$HOME/tmp/vmodem0
  echo "creating  ${dev} from ${1}:${port}"
  socat tcp-connect:${1}:${port} PTY,link=${dev}
}

# loops_from_image() {
  # loset -a

  # file $0|awk <<__EOAWK__
    # {
      # gsub(/:$/,"",$1) ; printf("IMAGEFILE=\"%s\"", $1)
    # }
  # __EOAWK__
  # losetup /dev/loop1 ArchLinuxARM-rpi-2-latest.img -o $((206848*512)) -s $((3763200*512))

# }
usb_start() {
  USBDISK=$1
  qemu-system-x86_64 -virtfs local,path=${PWD},mount_tag=host0,security_model=passthrough,id=host0 -device piix3-usb-uhci -drive id=my_usb_disk,file=${USBDISK},if=none -device usb-storage,drive=my_usb_disk
}


gh_clone() {
  DIR=$(echo $1 |sed -e "s#.*\(github.com.*\)\.git#$HOME\/\1# ; s/github.com:/github.com\//")
  git clone $1 $DIR
  cd $DIR
}

get_google_fonts() {
  cd "${HOME}"/.fonts
  curl -v -L https://github.com/google/fonts/archive/master.tar.gz |\
    tar xzv --one-top-level=google-fonts --strip-components=1
  fc-cache -fs > /dev/null
  mkfontscale "${PWD}"/google-fonts
  mkfontdir "${PWD}"/google-fonts

}

aa_256() {
  x=$(tput op)
  y=$(printf %$((${COLUMNS}/8))s)
  for i in {0..256}
  do
    o=00$i
    echo -en "${o:${#o}-3:3} $(tput setaf $i;tput setab $i)${y// /=}$x"
  done
}

msgsend() {
  FG="${darkgray}"
  BG="${blue}"
  MSG="${*}"

  echo "${MSG}" |dzen2 -fn Inconsolata-24:normal -y 640 -x 960 -w 1920 -h 64 \
  -bg "${BG}" -fg "${FG}" -p 4  -title-name Message
}

redebug() { perl -Mre=debugcolor -e "'$1'=~/$2/" ; }

toggletouchpad() {
  DEV="SynPS/2 Synaptics TouchPad"
  xinput $(xinput list-props "$DEV" |awk '/Device Enabled/ {print $4 == 1 ? "disable" : "enable"}') "$DEV"
}

_replace() {
  for i in $(grep -rl $1);
  do sed -i -e 's/$1/$2/g' $i
  done
}

replace() { set -x ; fd -t f -x sed -i -e "s/${1}/${2}/g" {} ; fd -x o={} n=${o//{${1}/${2}/} mv "${o}" "${n}" ; set +x ; }

setup_git_remote_origin() {
  REMOTE_COMMANDS="mkdir -p gitrepos/${1}.git; cd gitrepos/${1}.git; git init --bare"
  ssh slash@t5l.de $REMOTE_COMMANDS;
  echo now tell your repo to push to your new remote by saying:
  echo git remote add origin slash@t5l.de:gitrepos/${1}.git
  echo and
  echo git push -u origin master
  echo perhaps
}

mwiki() { dig +short txt $(echo $*|sed 's/ /_/g').wp.dg.cx|sed -E "s/\" \"|^\"|\"$|\\\\//g"|fmt; }

htpasswd_pass() {
  ruby -e "puts '$1'.crypt(rand(36**6).to_s(36))"
}

__gamma_blink() {
  ORIGGAMMA=$(xgamma 2>&1 |awk '{printf "xgamma -rgamma %f -ggamma %f -bgamma %f", $3, $5, $7}')
  xgamma -rgamma "${1}" -ggamma "${2}" -bgamma "${3}" >/dev/null 2>&1
  sleep 1
  $(${ORIGGAMMA} >/dev/null 2>&1)
}

signal_red() {
  __gamma_blink 4 0.1 0.1
}

signal_yellow() {
  __gamma_blink 4 4 0.1
}

signal_green() {
  __gamma_blink 0.1 4 0.1
}

prv() {
  fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
    file {} ||
    (highlight -O ansi -l {} ||
     coderay {} ||
     rougify {} ||
     cat {}) 2> /dev/null | head -500'
}

ch() {
  local cols sep sqlite_file open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'
  sqlite_file="$HOME/.config/chromium/Default/History"
  open=xdg-open
  cp -f "$sqlite_file" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  # fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
     fzf --ansi --multi --preview 'lynx -dump $(echo {}| sed "s#.*\(https*://\)#\1#")' | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

vcsv() { column -s,\; -t --table-header-repeat "${1:-/dev/stdin}"|sed -e "1i ${1:-/dev/stdin}"|less -#2 -N -S; }

sshdelhost() { sed -i -e "${1}d" /home/slash/.ssh/known_hosts ; }

uriencode() {
  if (( $# == 0 )) ; then
    read s
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
  printf %s "$s"
}

uridecode() {
  if (( $# == 0 )) ; then
    read s
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
  printf %s "$s"
}

gen_sscert() {
  pushd "${PWD}"
  local HOST=${1:-*}
  local WORKDIR=self_signed_cert_$(hexdump -v -e '/1 "%02x"' -n 16 /dev/urandom)
  local SUBJ="/C=DE"
  SUBJ+="/ST=Hamburg"
  SUBJ+="/L=Hamburg"
  SUBJ+="/O=Microprojects GmbH"
  SUBJ+="/OU=Self-Signer"
  SUBJ+="/CN=${HOST}.microprojects.de"
  local KEY=self_signed_key.pem
  local CSR=self_signed_csr.pem
  local CRT=self_signed_crt.pem
  mkdir "${WORKDIR}"
  cd "${WORKDIR}"
  openssl genrsa -out "${KEY}" 4096
  openssl req -new -subj "${SUBJ}" -key "${KEY}" -out "${CSR}"
  openssl x509 -req -days 3650 -in "${CSR}" -signkey "${KEY}" -out "${CRT}"
  popd
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
  fsize=$(stat "${infile}"|awk '/Size: /{print $2}') || return 1
  sudo dd if="${infile}" of="${outfile}" bs=128k status=progress \
    conv=sync 2>&1 |\
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
	if [ ! -d "${clonedir}" ]
	then
    git clone https://github.com/lewish/asciiflow2.git "${clonedir}"
		cd "${_}"
		./compile.sh
		chmod a+x closure-compiler.jar
	fi
	( sleep 1 ; xdg-open http://127.0.0.1:45311 ) &
	python3 -m http.server 45311 --bind 127.0.0.1
}

to() {
	local fifo="/tmp/${USER}_pipe"
	[ -e "${fifo}" ] || mkfifo "${fifo}"
	cat /dev/stdin > "${fifo}"
}

from() {
	local fifo="/tmp/${1}_pipe"
	cat "${fifo}"
}

killmetro() {
  # shellcheck disable=SC2046
  sudo kill $(ps axww -o user,pid|awk '/me[t]ro/{print $2}') |& \
    sed -e 's/kill: not enough arguments/nothing to do/'
}

metrovpn() {
  snx -d
  sleep 1
  pw="$(gopass show -o local/unix/snx@metro)"
  otp="$(gopass totp local/unix/snx@metro|awk '/^[0-9]{6}/{printf "%i", $1}')"
  printf "%s|%s" "${pw}" "${otp}"|snx
}

del_known_host_line() { sed -i ${1}d "${HOME}/.ssh/known_hosts" ; }
