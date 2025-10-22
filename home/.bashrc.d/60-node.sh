#!/bin/bash
dir="${HOME}/.yarn/bin" ; [ -d ${dir} ] && PATH+=":${dir}"
dir="${HOME}/node_modules/.bin" ; [ -d ${dir} ] && PATH+=":${dir}"
export NVM_DIR="$HOME/.nvm"
export NODE_REPL_HISTORY_FILE=~/.node_repl_history
export PATH
scr="/usr/share/nvm/nvm.sh" ; [ -e ${scr} ] && . ${scr} # >/dev/null 2>&1
scr="/usr/share/nvm/bash_completion" ; [ -e ${scr} ] && . ${scr} >/dev/null 2>&1
scr="/usr/share/nvm/install-nvm-exec" ; [ -e ${scr} ] && . ${scr} >/dev/null 2>&1
nvm use node
