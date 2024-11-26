#!/bin/sh

# System services
riverctl spawn "/usr/libexec/xfce-polkit"
riverctl spawn "wl-paste --type text --watch cliphist store"
riverctl spawn "wl-paste --type image --watch cliphist store"
riverctl spawn kanshi
riverctl spawn nm-applet
riverctl spawn waybar
riverctl spawn start_wlsunset

# Keyboard
riverctl set-repeat 30 260

# Trackpad
riverctl input "pointer-1452-613-Apple_Inc._Magic_Trackpad" tap enabled
riverctl input "pointer-1452-613-Apple_Inc._Magic_Trackpad" scroll-factor 0.3
riverctl input "pointer-1452-613-Apple_Inc._Magic_Trackpad" pointer-accel 0.11

# Cursor behavior
riverctl hide-cursor timeout 10000
riverctl hide-cursor when-typing enabled
riverctl set-cursor-warp on-focus-change
riverctl xcursor-theme "Bibata-Modern-Classic" 18
riverctl focus-follows-cursor always

# Environment initialization
dbus-update-activation-environment --all
gnome-keyring-daemon --start --components=secrets
/usr/libexec/pam_kwallet_init
