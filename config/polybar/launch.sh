#!/usr/bin/env sh

# check if hdmi is connected
if (xrandr | grep "HDMI-1 connected" > /dev/null)
then
    sleep 3
fi

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done

polybar traybar -c ~/.config/polybar/config &
polybar topbar1 -c ~/.config/polybar/config &
