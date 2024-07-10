from os.path import expanduser
from sys import path
from typing import Union

from libqtile import config, qtile
from libqtile.config import Click, Drag, EzConfig, EzKey, EzKeyChord, Key, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from .groups import groups

mod = "mod4"
alt = "mod1"
terminal = "kitty"
launcher = "rofi -modi drun,run -show drun"


keys = [
    ########
    ## Qtile
    EzKey("M-C-r", lazy.reload_config(), desc="Reload the config"),
    EzKey("M-C-S-q", lazy.shutdown(), desc="Shutdown Qtile"),
    EzKey("M-S-q", lazy.window.kill(), desc="Kill focused window"),
    EzKey(
        "M-f", lazy.next_layout(), desc="Toggle fullscreen for the current group"
    ),  # necessary for bonsai
    # EzKey("M-f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    EzKey(
        "A-f",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    #
    # Groups/monitors
    EzKey("M-<tab>", lazy.screen.next_group(), desc="Switch to next group"),
    EzKey("M-S-<tab>", lazy.screen.prev_group(), desc="Switch to previous group"),
    EzKey("M-<period>", lazy.next_screen(), desc="Move focus to next monitor"),
    EzKey("M-<comma>", lazy.prev_screen(), desc="Move focus to prev monitor"),
    EzKey(
        "M-S-<period>",
        lazy.move_window_to_next_screen(),
        desc="Move window to next monitor",
    ),
    EzKey(
        "M-S-<comma>",
        lazy.move_window_to_prev_screen(),
        desc="Move window to prev monitor",
    ),
    ########
    ## Bonsai
    # Splits
    EzKey("M-S-<Return>", lazy.spawn(guess_terminal()), desc="Fallback terminal"),
    EzKey("M-<minus>", lazy.layout.spawn_split(launcher, "y")),
    EzKey("M-<backslash>", lazy.layout.spawn_split(launcher, "x")),
    EzKey("M-S-<minus>", lazy.layout.spawn_split(launcher, "y", position="previous")),
    EzKey(
        "M-S-<backslash>",
        lazy.layout.spawn_split(launcher, "x", position="previous"),
    ),
    # terminal
    EzKey("M-A-<minus>", lazy.layout.spawn_split(terminal, "y")),
    EzKey("M-A-<backslash>", lazy.layout.spawn_split(terminal, "x")),
    EzKey("M-A-S-<minus>", lazy.layout.spawn_split(terminal, "y", position="previous")),
    EzKey(
        "M-A-S-<backslash>", lazy.layout.spawn_split(terminal, "x", position="previous")
    ),
    # aliases for original bindings
    EzKey("M-<Return>", lazy.layout.spawn_split(terminal, "x")),
    EzKey("M-<Space>", lazy.layout.spawn_split(launcher, "x")),
    EzKey(
        "M-S-<Return>",
        lazy.layout.spawn_split(guess_terminal(), "x"),
        desc="Fallback terminal",
    ),
    #
    # Move focus
    EzKey("M-h", lazy.layout.left()),
    EzKey("M-l", lazy.layout.right()),
    EzKey("M-k", lazy.layout.up()),
    EzKey("M-j", lazy.layout.down()),
    # Focus tabs
    EzKey("M-p", lazy.layout.prev_tab()),
    EzKey("M-n", lazy.layout.next_tab()),
    EzKey("M-<left>", lazy.layout.prev_tab()),
    EzKey("M-<right>", lazy.layout.next_tab()),
    EzKey("M-S-<left>", lazy.layout.swap_tabs("previous")),
    EzKey("M-S-<right>", lazy.layout.swap_tabs("next")),
    #
    # Resize
    EzKey("M-C-h", lazy.layout.resize("left", 100)),
    EzKey("M-C-l", lazy.layout.resize("right", 100)),
    EzKey("M-C-k", lazy.layout.resize("up", 100)),
    EzKey("M-C-j", lazy.layout.resize("down", 100)),
    #
    # Swap windows with neighbors
    EzKey("M-S-h", lazy.layout.swap("left")),
    EzKey("M-S-l", lazy.layout.swap("right")),
    EzKey("M-S-k", lazy.layout.swap("up")),
    EzKey("M-S-j", lazy.layout.swap("down")),
    #
    # Manipulate containers
    EzKey("M-v", lazy.layout.toggle_container_select_mode()),
    # EzKey("M-v", lazy.layout.enter_container_select_mode()),
    # EzKey("<escape>", lazy.layout.exit_container_select_mode()),
    EzKey("M-o", lazy.layout.select_container_outer()),
    EzKey("M-i", lazy.layout.select_container_inner()),
    #
    KeyChord(
        [mod],
        "t",
        [
            # Spawn new windows in new top-level tabs
            EzKey("M-<Return>", lazy.spawn(terminal)),
            EzKey("M-<space>", lazy.spawn(launcher)),
            # in same-/lower-level tabs
            EzKey("<return>", lazy.layout.spawn_tab(terminal)),
            EzKey("S-<return>", lazy.layout.spawn_tab(terminal, new_level=True)),
            EzKey("<space>", lazy.layout.spawn_tab(launcher)),
            EzKey("S-<space>", lazy.layout.spawn_tab(launcher, new_level=True)),
            #
            # Precise motions to move directly to specific tabs at the highest level
            EzKey("1", lazy.layout.focus_nth_tab(1, level=1)),
            EzKey("2", lazy.layout.focus_nth_tab(2, level=1)),
            EzKey("3", lazy.layout.focus_nth_tab(3, level=1)),
            EzKey("4", lazy.layout.focus_nth_tab(4, level=1)),
            EzKey("5", lazy.layout.focus_nth_tab(5, level=1)),
            EzKey("6", lazy.layout.focus_nth_tab(6, level=1)),
            EzKey("7", lazy.layout.focus_nth_tab(7, level=1)),
            EzKey("8", lazy.layout.focus_nth_tab(8, level=1)),
            EzKey("9", lazy.layout.focus_nth_tab(9, level=1)),
            EzKey("0", lazy.layout.focus_nth_tab(10, level=1)),
            #
            EzKey("b", lazy.layout.pull_out_to_tab()),
            EzKey("r", lazy.layout.rename_tab()),
            #
            EzKey("h", lazy.layout.prev_tab()),
            EzKey("l", lazy.layout.next_tab()),
            # Merge entire tabs with each other as splits
            EzKey("<left>", lazy.layout.merge_tabs("previous", "x")),
            EzKey("<right>", lazy.layout.merge_tabs("next", "x")),
            EzKey("S-<left>", lazy.layout.merge_tabs("previous", "y")),
            EzKey("S-<right>", lazy.layout.merge_tabs("next", "y")),
        ],
    ),
    KeyChord(
        [mod],
        "a",
        [
            # Pull windows out of tabs
            EzKey("e", lazy.layout.pull_out(position="next")),
            EzKey("S-e", lazy.layout.pull_out()),
            EzKey("C-e", lazy.layout.pull_out_to_tab()),
            # Precise motions to move directly to specific tabs at the nearest tab level
            EzKey("1", lazy.layout.focus_nth_tab(1, level=-1)),
            EzKey("2", lazy.layout.focus_nth_tab(2, level=-1)),
            EzKey("3", lazy.layout.focus_nth_tab(3, level=-1)),
            EzKey("4", lazy.layout.focus_nth_tab(4, level=-1)),
            EzKey("5", lazy.layout.focus_nth_tab(5, level=-1)),
            EzKey("6", lazy.layout.focus_nth_tab(6, level=-1)),
            EzKey("7", lazy.layout.focus_nth_tab(7, level=-1)),
            EzKey("8", lazy.layout.focus_nth_tab(8, level=-1)),
            EzKey("9", lazy.layout.focus_nth_tab(9, level=-1)),
            EzKey("0", lazy.layout.focus_nth_tab(10, level=-1)),
        ],
    ),
    KeyChord(
        [mod],
        "g",
        [
            # Directional commands to move window inside neighbor space.
            EzKey("j", lazy.layout.push_in("down")),
            EzKey("k", lazy.layout.push_in("up")),
            EzKey("h", lazy.layout.push_in("left")),
            EzKey("l", lazy.layout.push_in("right")),
            EzKey(
                "S-j",
                lazy.layout.push_in("down", dest_selection="mru_deepest"),
            ),
            EzKey(
                "S-k",
                lazy.layout.push_in("up", dest_selection="mru_deepest"),
            ),
            EzKey(
                "S-h",
                lazy.layout.push_in("left", dest_selection="mru_deepest"),
            ),
            EzKey(
                "S-l",
                lazy.layout.push_in("right", dest_selection="mru_deepest"),
            ),
            # Directional commands to merge windows with their neighbor into subtabs.
            EzKey("M-h", lazy.layout.merge_to_subtab("left")),
            EzKey("M-l", lazy.layout.merge_to_subtab("right")),
            EzKey("M-j", lazy.layout.merge_to_subtab("down")),
            EzKey("M-k", lazy.layout.merge_to_subtab("up")),
        ],
    ),
]

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
        EzKey(
            "<XF86AudioPrev>", lazy.spawn("playerctl previous"), desc="Previous Song"
        ),
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
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]
