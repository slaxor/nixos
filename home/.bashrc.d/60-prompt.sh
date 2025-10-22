#!/bin/bash
tt='\[\e]0;${USER}@${HOSTNAME}\007\]'
if [ ${UID} == 0 ]
then
  h='\[$(tput setaf 1)$(tput bold)\]\h\[$(tput sgr0)\]'
else
  if [ -f /usr/share/git/git-prompt.sh ]
  then
    source /usr/share/git/git-prompt.sh
    git='\[$(tput setaf 3)\]$(__git_ps1 "(%.10s)")\[$(tput sgr0)\]'
    GIT_PS1_SHOWDIRTYSTATE=true
  fi

  u='\[$(tput setaf 2)$(tput bold)\]\u\[$(tput sgr0)\]'
  at='\[$(tput setaf 4)\]@\[$(tput sgr0)\]'
  h='\[$(tput setaf 5)$(tput bold)\]\h\[$(tput sgr0)\]'
fi
cln='\[$(tput setaf 6)\]:\[$(tput sgr0)\]'
w='\[$(tput setaf 7)\]\w\[$(tput sgr0)\]'
dlr='\[$(tput setaf 7)\]\$ \[$(tput sgr0)\]'
export PS1="${tt}${git}${u}${at}${h}${cln}${w}${dlr}"

