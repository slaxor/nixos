#!/bin/bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# [ -f /usr/share/fzf/fzf-extras.bash ] && source /usr/share/fzf/fzf-extras.bash


base="${GOPATH}/src/github.com/junegunn/fzf"

if [ ! -d ${base} ]
then
  base="/usr/share/fzf"
fi

if [ -d ${base} ]
then
  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source "${base}/shell/completion.bash" 2> /dev/null

  # Key bindings
  # ------------
  if [ -f "${base}/key-bindings.bash" ]; then
    source "${base}/key-bindings.bash"
  fi

  complete -F _fzf_path_completion -o default -o bashdefault fd
  complete -F _fzf_dir_completion -o default -o bashdefault tree

  export FZF_DEFAULT_COMMAND='fd'
  export FZF_DEFAULT_OPTS='-m --reverse --inline-info'
fi
