tmux_send_everywhere() {
  for t in $(tmux list-panes -a -F '#S:#I.#P')
  do
    tmux send-keys -t ${t} $@
  done
}

tmux_send_panes() {
  for t in $(tmux list-panes -F '#S:#I.#P')
  do
    tmux send-keys -t ${t} $@
  done
}

