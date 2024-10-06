#!/bin/bash

# cpu
CPU_USAGE=$(top -l 2 -n 0 -F | grep -E "^CPU" | tail -1 | awk '{ print int($3 + $5) }')

# memory
MEMORY_USAGE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ print int(100-$5) }')

# volume
VOLUME=$(osascript -e 'output volume of (get volume settings)')
IS_MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$IS_MUTED" = "true" ] || [ $VOLUME -eq 0 ]; then
    VOLUME_ICON=""
elif [ $VOLUME -lt 50 ]; then
    VOLUME_ICON=""
else
    VOLUME_ICON=" "
fi

# combined
STATUS="  ${CPU_USAGE}% |   ${MEMORY_USAGE}% | ${VOLUME_ICON} ${VOLUME}%"
sketchybar --set $NAME label="$STATUS"
