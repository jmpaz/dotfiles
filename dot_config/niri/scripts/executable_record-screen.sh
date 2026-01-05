#!/bin/bash

set -eu

VIDEO_DIR="$HOME/Videos/Screencasts"
mkdir -p "$VIDEO_DIR"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send "$@"; }

notify_open_file() {
  local file="$1"
  local action_clicked=""

  if command -v notify-send >/dev/null 2>&1; then
    action_clicked=$(notify-send -t 6000 \
      --action=default="Open in Files" \
      "Recording saved" \
      "$(basename "$file")" || true)

    if [ "$action_clicked" = "default" ]; then
      if command -v nautilus >/dev/null 2>&1; then
        nautilus --select "$file" >/dev/null 2>&1 &
      else
        xdg-open "$(dirname "$file")" >/dev/null 2>&1 &
      fi
    fi
  fi
}

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="${RUNTIME_DIR}/wf-recorder-screen.state"

read_state() {
  [ -f "$STATE_FILE" ] || return 1
  PID="$(sed -n 's/^PID=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  FILE="$(sed -n 's/^FILE=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
}

stop_if_running() {
  if read_state; then
    if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
      kill -INT "$PID" 2>/dev/null || true
      for _ in {1..40}; do
        if ! kill -0 "$PID" 2>/dev/null; then
          break
        fi
        sleep 0.05
      done
      pkill -SIGRTMIN+8 waybar # hide recording indicator on waybar
      [ -n "${FILE:-}" ] && notify_open_file "$FILE"
      rm -f "$STATE_FILE"
      return 0
    fi
  fi

  # Fallback if state file is missing/stale.
  if pkill wf-recorder; then
    for _ in {1..20}; do
      if ! pgrep -x wf-recorder >/dev/null; then
        break
      fi
      sleep 0.05
    done
    pkill -SIGRTMIN+8 waybar
    rm -f "$STATE_FILE"
    return 0
  fi

  return 1
}

if stop_if_running; then
  exit 0
fi

FILENAME="$VIDEO_DIR/$(date +'Screencast From %Y-%m-%d %H-%M-%S.mp4')"

if geometry=$(slurp); then
  notify "Recording started" "$(basename "$FILENAME")"
  wf-recorder -g "$geometry" -f "$FILENAME" &
  PID=$!

  {
    printf 'PID=%s\n' "$PID"
    printf 'FILE=%s\n' "$FILENAME"
  } >"$STATE_FILE"

  sleep 0.1
  pkill -SIGRTMIN+8 waybar # display recording indicator on waybar
fi
