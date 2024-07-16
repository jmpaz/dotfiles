from os.path import expanduser
from sys import path
from typing import Union

from libqtile import config, qtile
from libqtile.config import Click, Drag, EzConfig, EzKey, EzKeyChord, Key, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from .groups import groups


# Helper functions
def window_to_adjacent_screen(qtile, direction, switch_group=False, focus_window=True, wrap=True):
    num_screens = len(qtile.screens)
    current_index = qtile.screens.index(qtile.current_screen)

    if direction == "next":
        target_index = (
            (current_index + 1) % num_screens if wrap else min(current_index + 1, num_screens - 1)
        )
    elif direction == "prev":
        target_index = (current_index - 1) % num_screens if wrap else max(current_index - 1, 0)
    else:
        return  # Invalid direction

    if target_index != current_index:
        group = qtile.screens[target_index].group.name
        qtile.current_window.togroup(group, switch_group=switch_group)
        if focus_window:
            qtile.cmd_to_screen(target_index)


@lazy.group.function
def toggle_max_monadtall(group):
    layout = group.layout.name
    if layout == "max":
        group.setlayout("monadtall")
    elif layout == "monadtall":
        group.setlayout("max")


mod = "mod4"
alt = "mod1"
# hyper = [mod, "shift", "control", alt]
# hyper_str = "M-S-C-A-"

terminal = "kitty"
launcher = "rofi -modi drun,run -show drun"


keys = [
    ########
    ## Windows
    EzKey("M-<return>", lazy.spawn(terminal), desc="Launch terminal"),
    EzKey("M-S-<return>", lazy.spawn(guess_terminal()), desc="Fallback terminal"),
    EzKey("M-<space>", lazy.spawn(launcher), desc="Launch rofi"),
    #
    EzKey("M-S-q", lazy.window.kill(), desc="Kill focused window"),
    EzKey("M-<grave>", lazy.next_layout()),
    EzKey("M-S-<grave>", lazy.prev_layout()),
    EzKey("M-f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    EzKey("M-m", toggle_max_monadtall, desc="Toggle max/monadtall layout"),
    EzKey(
        "A-f",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    ## Motions
    # Focus
    EzKey("M-h", lazy.layout.left()),
    EzKey("M-l", lazy.layout.right()),
    EzKey("M-k", lazy.layout.up()),
    EzKey("M-j", lazy.layout.down()),
    # Move
    EzKey("M-S-h", lazy.layout.shuffle_left(), lazy.layout.move_left()),
    EzKey("M-S-l", lazy.layout.shuffle_right(), lazy.layout.move_right()),
    EzKey("M-S-k", lazy.layout.shuffle_up(), lazy.layout.move_up()),
    EzKey("M-S-j", lazy.layout.shuffle_down(), lazy.layout.move_down()),
    # Resize
    EzKey(
        "M-C-h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        desc="Decrease active window size.",
    ),
    EzKey(
        "M-C-l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        desc="Increase active window size.",
    ),
    EzKey(
        "M-C-j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        desc="Decrease active window size.",
    ),
    EzKey(
        "M-C-k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        desc="Increase active window size.",
    ),
    EzKey(
        "M-n",
        lazy.layout.reset_size(),
        lazy.layout.normalize(),
        desc="Reset all window sizes",
    ),
    EzKey("M-C-r", lazy.layout.reset(), desc="Reset the sizes of all windows in group."),
    #
    # Manage groups/monitors
    EzKey("M-<tab>", lazy.screen.next_group(), desc="Switch to next group"),
    EzKey("M-S-<tab>", lazy.screen.prev_group(), desc="Switch to previous group"),
    EzKey("M-<period>", lazy.next_screen(), desc="Move focus to next monitor"),
    EzKey("M-<comma>", lazy.prev_screen(), desc="Move focus to prev monitor"),
    EzKey("M-S-<comma>", lazy.function(window_to_adjacent_screen, "next")),
    EzKey("M-S-<period>", lazy.function(window_to_adjacent_screen, "prev")),
    EzKey(
        "M-C-S-<comma>",
        lazy.function(window_to_adjacent_screen, "next", switch_group=True),
    ),
    EzKey(
        "M-C-S-<period>",
        lazy.function(window_to_adjacent_screen, "prev", switch_group=True),
    ),
    #
    ## Chords
    # KeyChord(hyper, "a", []),
    # KeyChord([mod], "a", []),
    # KeyChord([mod], "g", []),
    # KeyChord([mod], "t", []),
    #
    # Screenshots
    EzKey("M-S-s", lazy.spawn("flameshot gui")),
    KeyChord(
        [mod],
        "s",
        [
            # EzKey("M-s", lazy.spawn("flameshot gui")),
            EzKey(
                "f",
                lazy.spawn("flameshot screen -cp ~/Pictures/Screenshots"),
                desc="Capture the current display",
            ),
            EzKey(
                "f",
                lazy.spawn("flameshot full -cp ~/Pictures/Screenshots"),
                desc="Capture the entire desktop",
            ),
        ],
    ),
    ######
    ## System
    EzKey("M-C-r", lazy.reload_config(), desc="Reload the config"),
    EzKey("M-C-S-q", lazy.shutdown(), desc="Shutdown Qtile"),
]

# Layout-specific
plasma_keys = [
    # Resize
    EzKey("M-z", lazy.layout.grow_width(50)),
    EzKey("M-x", lazy.layout.grow_width(-50)),
    EzKey("M-C-z", lazy.layout.grow_height(50)),
    EzKey("M-C-x", lazy.layout.grow_height(-50)),
    # Integrate
    EzKey(
        "M-A-h", lazy.layout.swap_column_left(), lazy.layout.integrate_left()
    ),  # (columns + plasma)
    EzKey("M-A-l", lazy.layout.swap_column_right(), lazy.layout.integrate_right()),
    EzKey("M-A-k", lazy.layout.integrate_up()),
    EzKey("M-A-j", lazy.layout.integrate_down()),
    # Splits
    EzKey("M-d", lazy.layout.mode_horizontal()),
    EzKey("M-v", lazy.layout.mode_vertical()),
    EzKey("M-S-d", lazy.layout.mode_horizontal_split()),
    EzKey("M-S-v", lazy.layout.mode_vertical_split()),
]
keys.extend(plasma_keys)

monad_keys = [
    # Flip
    EzKey("M-A-f", lazy.layout.flip()),
]
keys.extend(monad_keys)

columns_keys = [
    # Flip
    EzKey("M-A-<space>", lazy.layout.toggle_split()),
]
keys.extend(columns_keys)

# Workspace
for i in groups:
    keys.extend(
        [
            EzKey(
                f"M-{i.name}",
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            EzKey(
                f"M-S-{i.name}",
                lazy.window.togroup(i.name),
                desc="move focused window to group {}".format(i.name),
            ),
        ]
    )


# Scratchpad
keys.extend(
    [
        # KeyChord([mod], "s", []),
        EzKey("M-C-<grave>", lazy.group["scratchpad"].dropdown_toggle("term")),
        EzKey("M-S-v", lazy.group["scratchpad"].dropdown_toggle("volume")),
        EzKey("M-S-o", lazy.group["scratchpad"].dropdown_toggle("obs")),
        EzKey("M-S-f", lazy.group["scratchpad"].dropdown_toggle("files")),
        EzKey("M-S-p", lazy.group["scratchpad"].dropdown_toggle("bitwarden")),
    ]
)


# Media keys
keys.extend(
    [
        EzKey(
            "<XF86AudioRaiseVolume>",
            lazy.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ +5%"),
            desc="Volume Up",
        ),
        EzKey(
            "S-<XF86AudioRaiseVolume>",
            lazy.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ +10%"),
            desc="Volume Up (2x)",
        ),
        EzKey(
            "<XF86AudioLowerVolume>",
            lazy.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ -5%"),
            desc="Volume Down",
        ),
        EzKey(
            "S-<XF86AudioLowerVolume>",
            lazy.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ -10%"),
            desc="Volume Down",
        ),
        EzKey(
            "<XF86AudioMute>",
            lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
            desc="Toggle Mute",
        ),
        EzKey("<XF86AudioPlay>", lazy.spawn("playerctl play-pause"), desc="Play/Pause"),
        EzKey("<XF86AudioNext>", lazy.spawn("playerctl next"), desc="Next Song"),
        EzKey("<XF86AudioPrev>", lazy.spawn("playerctl previous"), desc="Previous Song"),
        EzKey("<XF86AudioStop>", lazy.spawn("playerctl stop"), desc="Stop music"),
    ]
)


# Mouse bindings
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]
