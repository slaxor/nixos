gen_sscert() {
  pushd ${PWD}
  local host=${1:-*.microprojects.de}
  local prefix=self_signed
  local workdir=${prefix}_cert_$(date +%Y%m%d%H%M%S)
  local subj="/C=DE"
  subj+="/ST=Hamburg"
  subj+="/L=Hamburg"
  subj+="/O=Microprojects GmbH"
  subj+="/OU=Self-Signer"
  subj+="/CN=${HOST}"
  local cakey=${prefix}_cakey.pem
  local cacsr=${prefix}_cacsr.pem
  local cacrt=${prefix}_cacrt.pem
  local serial=${prefix}_cacrt.srl
  local key=${prefix}_key.pem
  local csr=${prefix}_csr.pem
  local crt=${prefix}_crt.pem
  mkdir ${workdir}
  cd ${workdir}
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
  local workdir=${prefix}_cert_$(date +%Y%m%d%H%M%S)
  local subj="/C=DE"
  subj+="/ST=Hamburg"
  subj+="/L=Hamburg"
  subj+="/O=Microprojects GmbH"
  subj+="/OU=Self-Signer"
  subj+="/CN=${HOST}"
  local cakey=*cakey.pem
  local cacrt=*cacrt.pem
  local serial=*.srl
  if [ -f ${cakey} ] && [ -f ${cacrt} ] &&[ -f ${serial} ]
  then
    local key=${prefix}_key.pem
    local csr=${prefix}_csr.pem
    local crt=${prefix}_crt.pem

    openssl genrsa -out ${key} 4096
    openssl req -new -subj "${subj}" -key ${key} -out ${csr}
    openssl x509 -req -days 3650 -in ${csr} -signkey ${key} -out ${crt} -CA ${cacrt} -CAkey ${cakey}
  else
    echo please go to the directory with  ${cakey}, ${cacrt} and ${serial} in it
  fi
}

