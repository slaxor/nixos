#!/bin/bash
set -x

case "${1}" in
  *.tar*) tar tf "${1}";;
  *.zip|*.[ejw]ar) unzip -l "${1}";;
  *.rar) unrar l "${1}";;
  *.7z) 7z l "${1}";;
  # *.pdf) pdftotext "${1}" -;;
  *.pdf) pdftoppm -png -f 1 -l 2 -progress "${1}"|/usr/bin/img2sixel -;;
#   *.pdf)
#     png_file="/tmp/$(basename "${1}")"
#     pdftoppm -png -f 1 -l 1 "${1}" "${png_file}"
#     chafa "${png_file}"-01.png
#     ;;
  *.csv) tabulate -1 -s ';' -f fancy_grid "${1}";;
  *.json) gojq  --indent=2 --color-output '.' <"${1}";;
  # *.yml|*.yaml) gojq --indent=2 --color-output --yaml-input '.' <"${1}";;
  *.jpg) viu "${1}";;
  *.md|*.markdown) glow "${1}";;
  *.pem) openssl x509 -text -in "${1}";;
  # *.pem|*.crt|*.der) openssl x509 -text "${1}";;
  *) pygmentize -O full,style=fruity,linenos=1 -f terminal256 "${1}" || strings "${1}";;
esac

