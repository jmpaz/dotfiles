#!/bin/bash

WINDOW_TITLE=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null || echo "No active window")
sketchybar --set $NAME label="${WINDOW_TITLE:0:50}"
