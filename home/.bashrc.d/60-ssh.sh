#!/bin/bash
export SSH_ENV="$HOME/.ssh/environment"

tunnel() {
  host=${1}
  serve=${2}
  listen=${3:-${host_port}}

  ssh ${host} -L ${serve}:localhost:${listen} -N
}

start_ssh_agent() {
     if [[ -e "${SSH_ENV}" ]]
     then
       . "${SSH_ENV}" >/dev/null
     fi

     if [[ -n ${SSH_AGENT_PID} ]] && ps ${SSH_AGENT_PID} >/dev/null 2>&1
     then
       return 0
     else
       echo "Initialising new SSH agent..."
       rm -f "${SSH_ENV}"
       /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
       echo succeeded
       chmod 600 "${SSH_ENV}"
       . "${SSH_ENV}" > /dev/null
       /usr/bin/ssh-add
     fi
}
start_ssh_agent


# if [ -f  "${SSH_ENV}" ] ; then
#     . "${SSH_ENV}" > /dev/null
#     if ! kill -0 $SSH_AGENT_PID > /dev/null 2>&1; then
#         echo "Stale agent file found. Spawning new agent… "
#         rm -f "${SSH_ENV}"
#         eval $(ssh-agent | tee "${SSH_ENV}")
#         ssh-add
#     fi
# else
#     echo "Starting ssh-agent"
#     rm -f "${SSH_ENV}"
#     eval $(ssh-agent | tee "${SSH_ENV}")
#     ssh-add
# fi
