#!/usr/bin/env bash
#
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


