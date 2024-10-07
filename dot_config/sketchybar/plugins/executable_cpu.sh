#!/bin/bash

CPU_USAGE=$(top -l 2 -n 0 -F | grep -E "^CPU" | tail -1 | awk '{ print int($3 + $5) "%"}')
sketchybar --set $NAME label="CPU: $CPU_USAGE"
