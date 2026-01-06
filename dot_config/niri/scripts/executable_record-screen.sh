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

usage() {
  cat <<'EOF'
Usage: record-screen.sh [--audio] [--system-audio] [--no-audio]

  --audio          Record default audio input (often microphone)
  --system-audio   Record output audio (default sink monitor)
  --no-audio       Disable audio (default)
EOF
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required but not installed." >&2
    exit 1
  fi
}

RECORD_AUDIO=false
RECORD_SYSTEM_AUDIO=false
RECORD_MODE="none"

for arg in "$@"; do
  case "$arg" in
    --audio)
      RECORD_AUDIO=true
      ;;
    --system-audio)
      RECORD_SYSTEM_AUDIO=true
      ;;
    --no-audio)
      RECORD_SYSTEM_AUDIO=false
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ "$RECORD_SYSTEM_AUDIO" = true ]; then
  RECORD_MODE="system"
elif [ "$RECORD_AUDIO" = true ]; then
  RECORD_MODE="mic"
fi

read_state() {
  [ -f "$STATE_FILE" ] || return 1
  PID="$(sed -n 's/^PID=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  FILE="$(sed -n 's/^FILE=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  TMP_FILE="$(sed -n 's/^TMP_FILE=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  RECORD_MODE="$(sed -n 's/^RECORD_MODE=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
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

      if [ "${RECORD_MODE:-none}" = "mic" ] && [ -n "${TMP_FILE:-}" ] && [ -n "${FILE:-}" ]; then
        if command -v ffmpeg >/dev/null 2>&1; then
          if ffmpeg -hide_banner -loglevel error -y \
            -i "$TMP_FILE" -c:v copy \
            -af "pan=stereo|c0=c0|c1=c0" \
            -c:a aac -map 0:v:0 -map 0:a:0 \
            "$FILE"; then
            rm -f "$TMP_FILE"
          else
            echo "Warning: audio postprocess failed; using raw recording." >&2
            mv -f "$TMP_FILE" "$FILE"
          fi
        else
          echo "Warning: ffmpeg not found; using raw recording." >&2
          mv -f "$TMP_FILE" "$FILE"
        fi
      fi

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
TMP_FILE=""

if geometry=$(slurp); then
  notify "Recording started" "$(basename "$FILENAME")"
  if [ "$RECORD_MODE" = "system" ]; then
    require_command pactl
    default_sink="$(pactl get-default-sink 2>/dev/null || true)"
    if [ -z "$default_sink" ]; then
      echo "Error: unable to determine default sink for system audio." >&2
      exit 1
    fi
    wf-recorder -y --audio="${default_sink}.monitor" -g "$geometry" -f "$FILENAME" &
  elif [ "$RECORD_MODE" = "mic" ]; then
    TMP_FILE="$(mktemp --tmpdir="$RUNTIME_DIR" --suffix=.mp4 wf-recorder-mic-XXXXXX)"
    rm -f "$TMP_FILE"
    wf-recorder -y -a -g "$geometry" -f "$TMP_FILE" &
  else
    wf-recorder -y -g "$geometry" -f "$FILENAME" &
  fi
  PID=$!

  {
    printf 'PID=%s\n' "$PID"
    printf 'FILE=%s\n' "$FILENAME"
    printf 'TMP_FILE=%s\n' "$TMP_FILE"
    printf 'RECORD_MODE=%s\n' "$RECORD_MODE"
  } >"$STATE_FILE"

  sleep 0.1
  pkill -SIGRTMIN+8 waybar # display recording indicator on waybar
fi
