#!/bin/bash
if [[ ! -z "${UPTERM_ADMIN_SOCKET}"  ]]
then
  set -o ignoreeof
  export UPTERM_ADMIN_SOCKET
  export PS1="🆙${PS1}"
fi
