# shellcheck shell=bash
_bubble() {
  local commands matches
  [[ ${COMP_CWORD} -eq 1 ]] || return 0
  commands=$(bubble __commands)
  matches=$(compgen -W "${commands}" -- "${COMP_WORDS[1]}") || return 0
  mapfile -t COMPREPLY <<<"${matches}"
}

complete -F _bubble bubble
