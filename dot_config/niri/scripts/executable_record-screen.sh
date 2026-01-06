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

TMP_BASE_DIR="${TMPDIR:-/var/tmp}"
TMP_DIR="${TMP_BASE_DIR%/}/wf-recorder-screen"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE_RUNTIME="${RUNTIME_DIR}/wf-recorder-screen.state"
STATE_FILE="${TMP_DIR}/wf-recorder-screen.state"
AUDIO_TMP_DIR="$TMP_DIR"

ensure_tmp_dir() {
  if [ ! -d "$TMP_DIR" ]; then
    if ! mkdir -p "$TMP_DIR" 2>/dev/null; then
      TMP_DIR="/tmp/wf-recorder-screen"
      mkdir -p "$TMP_DIR"
      STATE_FILE="${TMP_DIR}/wf-recorder-screen.state"
      AUDIO_TMP_DIR="$TMP_DIR"
    fi
  fi
}

cleanup_tmp_dir() {
  if [ -d "$TMP_DIR" ]; then
    find "$TMP_DIR" -maxdepth 1 -type f -name 'wf-recorder-*' -mmin +1440 -delete 2>/dev/null || true
  fi
  rm -f "${TMP_DIR}/wf-recorder-"* \
    "$STATE_FILE" \
    "$STATE_FILE_RUNTIME"
  rmdir "$TMP_DIR" 2>/dev/null || true
}

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

get_default_sink() {
  local sink=""
  sink="$(pactl get-default-sink 2>/dev/null || true)"
  if [ -z "$sink" ]; then
    sink="$(pactl info 2>/dev/null | sed -n 's/^Default Sink: //p' | head -n1)"
  fi
  if [ -z "$sink" ]; then
    sink="$(pactl list short sinks 2>/dev/null | awk 'NR==1{print $2}')"
  fi
  printf '%s' "$sink"
}

get_default_source() {
  local source=""
  source="$(pactl get-default-source 2>/dev/null || true)"
  if [ -z "$source" ]; then
    source="$(pactl info 2>/dev/null | sed -n 's/^Default Source: //p' | head -n1)"
  fi
  if [ -z "$source" ]; then
    source="$(pactl list short sources 2>/dev/null | awk '$2 !~ /\.monitor$/ {print $2; exit}')"
  fi
  printf '%s' "$source"
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
  local state_path="$STATE_FILE"
  if [ ! -f "$state_path" ] && [ -f "$STATE_FILE_RUNTIME" ]; then
    state_path="$STATE_FILE_RUNTIME"
  fi
  [ -f "$state_path" ] || return 1
  PID="$(sed -n 's/^PID=//p' "$state_path" 2>/dev/null | head -n1 || true)"
  FILE="$(sed -n 's/^FILE=//p' "$state_path" 2>/dev/null | head -n1 || true)"
  TMP_FILE="$(sed -n 's/^TMP_FILE=//p' "$state_path" 2>/dev/null | head -n1 || true)"
  VIDEO_TMP="$(sed -n 's/^VIDEO_TMP=//p' "$state_path" 2>/dev/null | head -n1 || true)"
  SYS_AUDIO="$(sed -n 's/^SYS_AUDIO=//p' "$state_path" 2>/dev/null | head -n1 || true)"
  MIC_AUDIO="$(sed -n 's/^MIC_AUDIO=//p' "$state_path" 2>/dev/null | head -n1 || true)"
  AUDIO_PID="$(sed -n 's/^AUDIO_PID=//p' "$state_path" 2>/dev/null | head -n1 || true)"
  RECORD_MODE="$(sed -n 's/^RECORD_MODE=//p' "$state_path" 2>/dev/null | head -n1 || true)"
}

write_state() {
  local state_path="$STATE_FILE"
  if ! {
    printf 'PID=%s\n' "$PID"
    printf 'FILE=%s\n' "$FILENAME"
    printf 'TMP_FILE=%s\n' "$TMP_FILE"
    printf 'VIDEO_TMP=%s\n' "$VIDEO_TMP"
    printf 'SYS_AUDIO=%s\n' "$SYS_AUDIO"
    printf 'MIC_AUDIO=%s\n' "$MIC_AUDIO"
    printf 'AUDIO_PID=%s\n' "$AUDIO_PID"
    printf 'RECORD_MODE=%s\n' "$RECORD_MODE"
  } >"$state_path"; then
    state_path="$STATE_FILE_RUNTIME"
    {
      printf 'PID=%s\n' "$PID"
      printf 'FILE=%s\n' "$FILENAME"
      printf 'TMP_FILE=%s\n' "$TMP_FILE"
      printf 'VIDEO_TMP=%s\n' "$VIDEO_TMP"
      printf 'SYS_AUDIO=%s\n' "$SYS_AUDIO"
      printf 'MIC_AUDIO=%s\n' "$MIC_AUDIO"
      printf 'AUDIO_PID=%s\n' "$AUDIO_PID"
      printf 'RECORD_MODE=%s\n' "$RECORD_MODE"
    } >"$state_path"
  fi
}

stop_if_running() {
  if read_state; then
    local recorder_running=false
    local pending_output=false

    if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
      kill -INT "$PID" 2>/dev/null || true
      for _ in {1..40}; do
        if ! kill -0 "$PID" 2>/dev/null; then
          break
        fi
        sleep 0.05
      done
      recorder_running=true
    elif pgrep -x wf-recorder >/dev/null 2>&1; then
      pkill wf-recorder
      for _ in {1..20}; do
        if ! pgrep -x wf-recorder >/dev/null; then
          break
        fi
        sleep 0.05
      done
      recorder_running=true
    fi

    if [ "${RECORD_MODE:-none}" = "mic" ] && [ -n "${VIDEO_TMP:-}" ] && [ -f "$VIDEO_TMP" ]; then
      pending_output=true
    elif [ "${RECORD_MODE:-none}" = "mixed" ] && [ -n "${VIDEO_TMP:-}" ] && [ -f "$VIDEO_TMP" ]; then
      pending_output=true
    fi

    if [ "$recorder_running" = true ] || [ "$pending_output" = true ]; then
      pkill -SIGRTMIN+8 waybar # hide recording indicator on waybar

      if [ "${RECORD_MODE:-none}" = "mic" ]; then
        if [ -n "${AUDIO_PID:-}" ] && kill -0 "$AUDIO_PID" 2>/dev/null; then
          kill -INT "$AUDIO_PID" 2>/dev/null || true
          for _ in {1..40}; do
            if ! kill -0 "$AUDIO_PID" 2>/dev/null; then
              break
            fi
            sleep 0.05
          done
        fi
        if [ -n "${VIDEO_TMP:-}" ] && [ -f "$VIDEO_TMP" ] && [ -n "${FILE:-}" ]; then
          if [ -n "${MIC_AUDIO:-}" ] && [ -f "$MIC_AUDIO" ] && command -v ffmpeg >/dev/null 2>&1; then
            if ffmpeg -hide_banner -loglevel error -y \
              -i "$VIDEO_TMP" \
              -i "$MIC_AUDIO" \
              -filter_complex "[1:a]aformat=sample_rates=48000:channel_layouts=mono,pan=stereo|c0=c0|c1=c0[mic]" \
              -map 0:v:0 -c:v copy \
              -map "[mic]" -c:a aac \
              "$FILE"; then
              rm -f "$VIDEO_TMP" "$MIC_AUDIO"
            else
              echo "Warning: audio mux failed; using video-only recording." >&2
              mv -f "$VIDEO_TMP" "$FILE"
              rm -f "$MIC_AUDIO"
            fi
          else
            if [ -n "${MIC_AUDIO:-}" ] && [ -f "$MIC_AUDIO" ]; then
              echo "Warning: ffmpeg not found; using video-only recording." >&2
              rm -f "$MIC_AUDIO"
            fi
            mv -f "$VIDEO_TMP" "$FILE"
          fi
        fi
      fi

      if [ "${RECORD_MODE:-none}" = "mixed" ]; then
        if [ -n "${AUDIO_PID:-}" ] && kill -0 "$AUDIO_PID" 2>/dev/null; then
          kill -INT "$AUDIO_PID" 2>/dev/null || true
          for _ in {1..40}; do
            if ! kill -0 "$AUDIO_PID" 2>/dev/null; then
              break
            fi
            sleep 0.05
          done
        fi
        if [ -n "${VIDEO_TMP:-}" ] && [ -f "$VIDEO_TMP" ] && [ -n "${FILE:-}" ]; then
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
      fi

      [ -n "${FILE:-}" ] && notify_open_file "$FILE"
      cleanup_tmp_dir
      return 0
    fi

    cleanup_tmp_dir
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
    cleanup_tmp_dir
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

ensure_tmp_dir

if geometry=$(slurp); then
  notify "Recording started" "$(basename "$FILENAME")"
  if [ "$RECORD_MODE" = "system" ]; then
    require_command pactl
    default_sink="$(get_default_sink)"
    if [ -z "$default_sink" ]; then
      echo "Error: unable to determine default sink for system audio." >&2
      exit 1
    fi
    wf-recorder -y --audio="${default_sink}.monitor" -g "$geometry" -f "$FILENAME" &
  elif [ "$RECORD_MODE" = "mic" ]; then
    VIDEO_TMP="$(mktemp --tmpdir="$VIDEO_DIR" --suffix=.mp4 wf-recorder-mic-video-XXXXXX)"
    rm -f "$VIDEO_TMP"
    default_source=""
    if command -v pactl >/dev/null 2>&1; then
      default_source="$(get_default_source)"
    fi
    if [ -n "$default_source" ] && command -v ffmpeg >/dev/null 2>&1; then
      MIC_AUDIO="$(mktemp --tmpdir="$AUDIO_TMP_DIR" --suffix=.wav wf-recorder-mic-XXXXXX)"
      rm -f "$MIC_AUDIO"
      ffmpeg -hide_banner -loglevel error -y \
        -f pulse -i "${default_source}" \
        -map 0:a -c:a pcm_s16le "$MIC_AUDIO" &
      AUDIO_PID=$!
    else
      if [ -z "$default_source" ]; then
        echo "Warning: unable to determine default source; recording video only." >&2
      else
        echo "Warning: ffmpeg not found; recording video only." >&2
      fi
    fi
    wf-recorder -y -g "$geometry" -f "$VIDEO_TMP" &
  elif [ "$RECORD_MODE" = "mixed" ]; then
    require_command pactl
    require_command ffmpeg
    default_sink="$(get_default_sink)"
    if [ -z "$default_sink" ]; then
      echo "Error: unable to determine default sink for system audio." >&2
      exit 1
    fi
    default_source="$(get_default_source)"
    if [ -z "$default_source" ]; then
      echo "Error: unable to determine default source for mic audio." >&2
      exit 1
    fi
    VIDEO_TMP="$(mktemp --tmpdir="$VIDEO_DIR" --suffix=.mp4 wf-recorder-video-XXXXXX)"
    rm -f "$VIDEO_TMP"
    SYS_AUDIO="$(mktemp --tmpdir="$AUDIO_TMP_DIR" --suffix=.wav wf-recorder-sys-XXXXXX)"
    MIC_AUDIO="$(mktemp --tmpdir="$AUDIO_TMP_DIR" --suffix=.wav wf-recorder-mic-XXXXXX)"
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

  write_state

  sleep 0.1
  pkill -SIGRTMIN+8 waybar # display recording indicator on waybar
fi
