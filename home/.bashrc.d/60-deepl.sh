#!/bin/bash
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
  curl -q -X POST --data "${data}" "${url}"|jq '.data, .alternatives'
}


esde() { tl8 "ES" "DE" "${1}" ; }
dees() { tl8 "DE" "ES" "${1}" ;  }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This script is meant to be sourced, not run directly."
  exit 1
fi
