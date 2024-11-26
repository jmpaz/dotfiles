
## window management
# launch terminal and application launcher
riverctl map normal Super Return spawn '~/.local/bin/ghostty'
riverctl map normal Super D spawn "rofi -show drun"

# close windows
riverctl map normal Super+Shift Q close

# focus/swap views
riverctl map normal Super J focus-view next
riverctl map normal Super K focus-view previous
riverctl map normal Super+Shift J swap next
riverctl map normal Super+Shift K swap previous
riverctl map normal Super N focus-view next
riverctl map normal Super P focus-view previous
riverctl map normal Super+Shift N swap next
riverctl map normal Super+Shift P swap previous

# # move views
# riverctl map normal Super+Alt H move left 100
# riverctl map normal Super+Alt J move down 100
# riverctl map normal Super+Alt K move up 100
# riverctl map normal Super+Alt L move right 100

## tag management
for i in $(seq 1 9); do
    tag=$((1 << ($i - 1)))
    riverctl map normal Super $i set-focused-tags $tag
    riverctl map normal Super+Shift $i set-view-tags $tag
    riverctl map normal Super+Alt $i toggle-focused-tags $tag
    riverctl map normal Super+Alt+Shift $i toggle-view-tags $tag
done

# focus all tags
all_tags=$(((1 << 32) - 1))
riverctl map normal Super 0 set-focused-tags $all_tags
riverctl map normal Super+Shift 0 set-view-tags $all_tags

# scratchpads
term_tag=$((1 << 19))
filemanager_tag=$((1 << 20))
discord_tag=$((1 << 21))

## extra tags
# scratchpads
scratchpad_tag=$((1 << 19))
riverctl map normal Super grave toggle-focused-tags $scratchpad_tag
riverctl map normal Super+Shift grave set-view-tags $scratchpad_tag


## modes
# screenshot
riverctl declare-mode screenshot
riverctl map normal Super S enter-mode screenshot
riverctl map screenshot None Escape enter-mode normal
riverctl map screenshot None F spawn 'grim - | tee ~/Pictures/screenshots/screenshot-$(date +%Y-%m-%d-%H%M%S).png | wl-copy && riverctl enter-mode normal'
riverctl map screenshot None R spawn 'grim -g "$(slurp)" - | tee ~/Pictures/screenshots/screenshot-$(date +%Y-%m-%d-%H%M%S).png | wl-copy && riverctl enter-mode normal'

## layout: wideriver
riverctl map normal Super H send-layout-cmd wideriver "--ratio -0.05"
riverctl map normal Super L send-layout-cmd wideriver "--ratio +0.05"
riverctl map normal Super+Shift H send-layout-cmd wideriver "--count +1"
riverctl map normal Super+Shift L send-layout-cmd wideriver "--count -1"

riverctl map normal Super Escape send-layout-cmd wideriver "--ratio 0.5"
riverctl map normal Super+Shift Escape send-layout-cmd wideriver "--count 1"
riverctl map normal Super+Shift D send-layout-cmd wideriver "--stack diminish"
riverctl map normal Super+Shift W send-layout-cmd wideriver "--stack dwindle"
riverctl map normal Super+Shift E send-layout-cmd wideriver "--stack even"

# orientation
riverctl map normal Super Up send-layout-cmd wideriver "--layout top"
riverctl map normal Super Right send-layout-cmd wideriver "--layout right"
riverctl map normal Super Down send-layout-cmd wideriver "--layout bottom"
riverctl map normal Super Left send-layout-cmd wideriver "--layout left"

# layout toggle
riverctl map normal Super M send-layout-cmd wideriver "--layout monocle"
riverctl map normal Super F2 send-layout-cmd wideriver "--layout wide"
riverctl map normal Super W send-layout-cmd wideriver "--layout-toggle"

## fullscreen, float, zoom
riverctl map normal Super Space toggle-float
riverctl map normal Super F toggle-fullscreen
riverctl map normal Super+Shift Return zoom

## mouse
riverctl map-pointer normal Super BTN_LEFT move-view
riverctl map-pointer normal Super BTN_RIGHT resize-view
riverctl map-pointer normal Super BTN_MIDDLE toggle-float


# ## floating mode
# riverctl declare-mode floating
# riverctl map normal Super+Alt F enter-mode floating
# riverctl map floating None Escape enter-mode normal

# # resize floating windows by 25px
# riverctl map -repeat floating None H resize horizontal -25
# riverctl map -repeat floating None J resize vertical 25
# riverctl map -repeat floating None K resize vertical -25
# riverctl map -repeat floating None L resize horizontal 25

# # move floating windows by 25px
# riverctl map -repeat floating Super H move left 25
# riverctl map -repeat floating Super J move down 25
# riverctl map -repeat floating Super K move up 25
# riverctl map -repeat floating Super L move right 25

# # snap floating windows to screen edges
# riverctl map floating Super+Shift H snap left
# riverctl map floating Super+Shift J snap down
# riverctl map floating Super+Shift K snap up
# riverctl map floating Super+Shift L snap right

## resize mode
riverctl declare-mode resize
riverctl map normal Super+Alt R enter-mode resize
riverctl map resize None Escape enter-mode normal

# adjust layout orientation
riverctl map resize None Up send-layout-cmd wideriver "--layout top"
riverctl map resize None Right send-layout-cmd wideriver "--layout right"
riverctl map resize None Down send-layout-cmd wideriver "--layout bottom"
riverctl map resize None Left send-layout-cmd wideriver "--layout left"

# adjust layout ratios
riverctl map resize Super H send-layout-cmd wideriver "--ratio -0.05"
riverctl map resize Super L send-layout-cmd wideriver "--ratio +0.05"

# adjust master count
riverctl map resize Super+Shift H send-layout-cmd wideriver "--count +1"
riverctl map resize Super+Shift L send-layout-cmd wideriver "--count -1"

## system
for mode in normal locked; do
    # volume
    riverctl map $mode None XF86AudioRaiseVolume spawn 'pamixer -i 5'
    riverctl map $mode None XF86AudioLowerVolume spawn 'pamixer -d 5'
    riverctl map $mode None XF86AudioMute spawn 'pamixer --toggle-mute'

    # media
    riverctl map $mode None XF86AudioPlay spawn 'playerctl play-pause'
    riverctl map $mode None XF86AudioPrev spawn 'playerctl previous'
    riverctl map $mode None XF86AudioNext spawn 'playerctl next'

    # brightness
    riverctl map $mode None XF86MonBrightnessUp spawn 'brightnessctl s +5%'
    riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl s 5%-'
done

# clipboard
riverctl map normal Super V spawn "cliphist list | rofi -dmenu -p 'Clipboard' -config $HOME/.config/rofi/regular.rasi | cliphist decode | wl-copy"
