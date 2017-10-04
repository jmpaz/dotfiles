kedit() {
  nohup kate "$@" 2>&1 1>/dev/null & disown
}

