#!/bin/bash
[[ $- != *i* ]] && return
TIMEFORMAT="%R"
[[ -f /etc/profile ]] && . /etc/profile
if [ -d "${HOME}/.bashrc.d" ]; then
  for i in "${HOME}/.bashrc.d"/*.sh
  do
    if [ -r "${i}" ]; then
      # s=$(date +%s.%N)
      source "${i}"
      # f=$(date +%s.%N)
      # printf "sourcing %s took %1.4fs\n" "${i}" $(bc -l <<< "${f}-${s}")
    fi
  done
  unset i, TIMEFORMAT
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source /home/slash/.bash_completions/oterm.sh
