#!/bin/bash

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="${RUNTIME_DIR}/wf-recorder-screen.state"
COLOR_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/colors.css"

get_color2() {
  if [ -r "$COLOR_FILE" ]; then
    awk '/^@define-color[[:space:]]+color2[[:space:]]+/ { gsub(";", "", $3); print $3; exit }' "$COLOR_FILE"
  fi
}

if pgrep -x wf-recorder >/dev/null; then
  FILE=""
  if [ -r "$STATE_FILE" ]; then
    FILE="$(sed -n 's/^FILE=//p' "$STATE_FILE" 2>/dev/null | head -n1 || true)"
  fi

  if [ -n "$FILE" ]; then
    TOOLTIP="Recording ${FILE}..."
  else
    TOOLTIP="Recording..."
  fi

  TOOLTIP_ESCAPED=$(printf '%s' "$TOOLTIP" | sed 's/"/\\"/g')
  COLOR2="$(get_color2)"
  if [ -n "$COLOR2" ]; then
    TEXT="<span foreground=\"$COLOR2\">●</span> REC"
  else
    TEXT="● REC"
  fi

  TEXT_ESCAPED=$(printf '%s' "$TEXT" | sed 's/"/\\"/g')
  printf '{"text": "%s", "tooltip": "%s", "class": "recording"}\n' "$TEXT_ESCAPED" "$TOOLTIP_ESCAPED"
else
  echo '{}'
fi
