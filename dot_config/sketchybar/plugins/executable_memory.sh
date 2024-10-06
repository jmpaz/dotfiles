#!/bin/bash

MEMORY_USAGE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ print int(100-$5) "%" }')
sketchybar --set $NAME label="MEM: $MEMORY_USAGE"
