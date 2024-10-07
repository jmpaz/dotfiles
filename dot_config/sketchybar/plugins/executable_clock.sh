#!/bin/bash

sketchybar --set $NAME label=" $(date '+%d %b | %I:%M%p' | sed 's/AM/am/;s/PM/pm/' | tr '[:upper:]' '[:lower:]')"
