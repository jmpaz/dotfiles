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
Usage: record-screen.sh [--audio] [--system-audio] [--mixed-audio] [--no-audio]

  --audio          Record default audio input (often microphone)
  --system-audio   Record output audio (default sink monitor)
  --mixed-audio    Record system + mic and mux as 3 tracks (mix, mic, system)
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
RECORD_MIXED=false
RECORD_MODE="none"

for arg in "$@"; do
  case "$arg" in
    --audio)
      RECORD_AUDIO=true
      ;;
    --system-audio)
      RECORD_SYSTEM_AUDIO=true
      ;;
    --mixed-audio)
      RECORD_MIXED=true
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

if [ "$RECORD_MIXED" = true ]; then
  RECORD_MODE="mixed"
elif [ "$RECORD_SYSTEM_AUDIO" = true ]; then
  RECORD_MODE="system"
elif [ "$RECORD_AUDIO" = true ]; then
  RECORD_MODE="mic"
fi

read_state() {
  [ -f "$STATE_FILE" ] || return 1
  PID="$(sed -n 's/^PID=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  FILE="$(sed -n 's/^FILE=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  TMP_FILE="$(sed -n 's/^TMP_FILE=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  VIDEO_TMP="$(sed -n 's/^VIDEO_TMP=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  SYS_AUDIO="$(sed -n 's/^SYS_AUDIO=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  MIC_AUDIO="$(sed -n 's/^MIC_AUDIO=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  AUDIO_PID="$(sed -n 's/^AUDIO_PID=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
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

      if [ "${RECORD_MODE:-none}" = "mixed" ] && [ -n "${VIDEO_TMP:-}" ] && [ -n "${FILE:-}" ]; then
        if [ -n "${AUDIO_PID:-}" ] && kill -0 "$AUDIO_PID" 2>/dev/null; then
          kill -INT "$AUDIO_PID" 2>/dev/null || true
          for _ in {1..40}; do
            if ! kill -0 "$AUDIO_PID" 2>/dev/null; then
              break
            fi
            sleep 0.05
          done
        fi
        if [ -z "${SYS_AUDIO:-}" ] || [ -z "${MIC_AUDIO:-}" ]; then
          echo "Warning: missing audio temp files; using video-only recording." >&2
          mv -f "$VIDEO_TMP" "$FILE"
        elif command -v ffmpeg >/dev/null 2>&1; then
          if ffmpeg -hide_banner -loglevel error -y \
            -i "$VIDEO_TMP" \
            -i "$SYS_AUDIO" \
            -i "$MIC_AUDIO" \
            -filter_complex "[1:a]aformat=sample_rates=48000:channel_layouts=stereo[sys];[2:a]aformat=sample_rates=48000:channel_layouts=mono,pan=stereo|c0=c0|c1=c0[mic];[sys]asplit=2[sysmix][sysout];[mic]asplit=2[micmix][micout];[sysmix][micmix]amix=inputs=2:normalize=0[mix]" \
            -map 0:v:0 -c:v copy \
            -map "[mix]" -c:a aac \
            -map "[micout]" -c:a aac \
            -map "[sysout]" -c:a aac \
            "$FILE"; then
            rm -f "$VIDEO_TMP" "$SYS_AUDIO" "$MIC_AUDIO"
          else
            echo "Warning: audio mux failed; using video-only recording." >&2
            mv -f "$VIDEO_TMP" "$FILE"
            rm -f "$SYS_AUDIO" "$MIC_AUDIO"
          fi
        else
          echo "Warning: ffmpeg not found; using video-only recording." >&2
          mv -f "$VIDEO_TMP" "$FILE"
          rm -f "$SYS_AUDIO" "$MIC_AUDIO"
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
VIDEO_TMP=""
SYS_AUDIO=""
MIC_AUDIO=""
AUDIO_PID=""

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
  elif [ "$RECORD_MODE" = "mixed" ]; then
    require_command pactl
    require_command ffmpeg
    default_sink="$(pactl get-default-sink 2>/dev/null || true)"
    if [ -z "$default_sink" ]; then
      echo "Error: unable to determine default sink for system audio." >&2
      exit 1
    fi
    default_source="$(pactl get-default-source 2>/dev/null || true)"
    if [ -z "$default_source" ]; then
      echo "Error: unable to determine default source for mic audio." >&2
      exit 1
    fi
    VIDEO_TMP="$(mktemp --tmpdir="$RUNTIME_DIR" --suffix=.mp4 wf-recorder-video-XXXXXX)"
    rm -f "$VIDEO_TMP"
    SYS_AUDIO="$(mktemp --tmpdir="$RUNTIME_DIR" --suffix=.wav wf-recorder-sys-XXXXXX)"
    MIC_AUDIO="$(mktemp --tmpdir="$RUNTIME_DIR" --suffix=.wav wf-recorder-mic-XXXXXX)"
    rm -f "$SYS_AUDIO" "$MIC_AUDIO"
    ffmpeg -hide_banner -loglevel error -y \
      -f pulse -i "${default_sink}.monitor" \
      -f pulse -i "${default_source}" \
      -map 0:a -c:a pcm_s16le "$SYS_AUDIO" \
      -map 1:a -c:a pcm_s16le "$MIC_AUDIO" &
    AUDIO_PID=$!
    wf-recorder -y -g "$geometry" -f "$VIDEO_TMP" &
  else
    wf-recorder -y -g "$geometry" -f "$FILENAME" &
  fi
  PID=$!

  {
    printf 'PID=%s\n' "$PID"
    printf 'FILE=%s\n' "$FILENAME"
    printf 'TMP_FILE=%s\n' "$TMP_FILE"
    printf 'VIDEO_TMP=%s\n' "$VIDEO_TMP"
    printf 'SYS_AUDIO=%s\n' "$SYS_AUDIO"
    printf 'MIC_AUDIO=%s\n' "$MIC_AUDIO"
    printf 'AUDIO_PID=%s\n' "$AUDIO_PID"
    printf 'RECORD_MODE=%s\n' "$RECORD_MODE"
  } >"$STATE_FILE"

  sleep 0.1
  pkill -SIGRTMIN+8 waybar # display recording indicator on waybar
fi
