#!/usr/bin/env sh
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done

polybar traybar -c ~/.config/polybar/config &
polybar topbar1 -c ~/.config/polybar/config &