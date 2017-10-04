walset() {
  wal -n -ti "$@"
  feh --bg-scale "$(< "${HOME}/.cache/wal/wal")"
}

