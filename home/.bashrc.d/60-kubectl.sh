source <(kubectl completion bash)

alias k=kubectl
alias kctx=kubectx
alias kns=kubens

complete -F __start_kubectl k

export PATH="${PATH}:${HOME}/.krew/bin"
