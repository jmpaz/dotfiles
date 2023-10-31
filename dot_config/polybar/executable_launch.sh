#!/bin/sh

if [ -z "$(pgrep -x polybar)" ]; then
	BAR="topbar1"
	for m in $(polybar --list-monitors | cut -d":" -f1); do
		echo "Launching polybar on $m"
		MONITOR=$m polybar --reload $BAR &
		sleep 1
	done
else
	polybar-msg cmd restart
fi
