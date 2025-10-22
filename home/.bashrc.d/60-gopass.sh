#!/bin/bash
gopass=$(go env GOPATH)/bin/gopass
# echo -e "GET /ping HTTP/1.0\nHost: localhost\n" |socat /home/slash/.config/gopass/.gopass-agent.sock - >/dev/null 2>&1 &
if [ $? != 0 ] && [ -f ${gopass} ]
then
  nohup ${gopass} agent >/dev/null 2>&1 &
fi
source <(gopass completion bash)
# Simply copy the selected password to the clipboard
alias pwc='gopass ls --flat | fzf | xargs --no-run-if-empty gopass show -c'
# First pipe the selected name to gopass, encrypt it and type the password with xdotool.
#  gopass ls --flat | dmenu | xargs --no-run-if-empty gopass show -f | head -n 1 | xdotool type --clearmodifiers --file -
