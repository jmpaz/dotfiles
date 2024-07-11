from os.path import expanduser
from sys import path
from typing import Union

from libqtile import config, qtile
from libqtile.config import Click, Drag, EzConfig, EzKey, EzKeyChord, Key, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from .groups import groups


# Helper functions
def window_to_adjacent_screen(
    qtile, direction, switch_group=False, focus_window=True, wrap=True
):
    num_screens = len(qtile.screens)
    current_index = qtile.screens.index(qtile.current_screen)

    if direction == "next":
        target_index = (
            (current_index + 1) % num_screens
            if wrap
            else min(current_index + 1, num_screens - 1)
        )
    elif direction == "prev":
        target_index = (
            (current_index - 1) % num_screens if wrap else max(current_index - 1, 0)
        )
    else:
        return  # Invalid direction

    if target_index != current_index:
        group = qtile.screens[target_index].group.name
        qtile.current_window.togroup(group, switch_group=switch_group)
        if focus_window:
            qtile.cmd_to_screen(target_index)


mod = "mod4"
alt = "mod1"
# hyper = [mod, "shift", "control", alt]
# hyper_str = "M-S-C-A-"

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
    # aliases for standard bindings
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
    EzKey("M-S-p", lazy.layout.swap_tabs("previous")),
    EzKey("M-S-n", lazy.layout.swap_tabs("next")),
    EzKey("M-<left>", lazy.layout.prev_tab()),
    EzKey("M-<right>", lazy.layout.next_tab()),
    EzKey("M-S-<left>", lazy.layout.swap_tabs("previous")),
    EzKey("M-S-<right>", lazy.layout.swap_tabs("next")),
    # Focus nth tab at nearest level
    EzKey("M-1", lazy.layout.focus_nth_tab(1, level=-1)),
    EzKey("M-2", lazy.layout.focus_nth_tab(2, level=-1)),
    EzKey("M-3", lazy.layout.focus_nth_tab(3, level=-1)),
    EzKey("M-4", lazy.layout.focus_nth_tab(4, level=-1)),
    EzKey("M-5", lazy.layout.focus_nth_tab(5, level=-1)),
    EzKey("M-6", lazy.layout.focus_nth_tab(6, level=-1)),
    EzKey("M-7", lazy.layout.focus_nth_tab(7, level=-1)),
    EzKey("M-8", lazy.layout.focus_nth_tab(8, level=-1)),
    EzKey("M-9", lazy.layout.focus_nth_tab(9, level=-1)),
    EzKey("M-0", lazy.layout.focus_nth_tab(10, level=-1)),
    # Focus nth root-level tab
    EzKey("C-M-1", lazy.layout.focus_nth_tab(1, level=1)),
    EzKey("C-M-2", lazy.layout.focus_nth_tab(2, level=1)),
    EzKey("C-M-3", lazy.layout.focus_nth_tab(3, level=1)),
    EzKey("C-M-4", lazy.layout.focus_nth_tab(4, level=1)),
    EzKey("C-M-5", lazy.layout.focus_nth_tab(5, level=1)),
    EzKey("C-M-6", lazy.layout.focus_nth_tab(6, level=1)),
    EzKey("C-M-7", lazy.layout.focus_nth_tab(7, level=1)),
    EzKey("C-M-8", lazy.layout.focus_nth_tab(8, level=1)),
    EzKey("C-M-9", lazy.layout.focus_nth_tab(9, level=1)),
    EzKey("C-M-0", lazy.layout.focus_nth_tab(10, level=1)),
    #
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
    EzKey("M-v", lazy.layout.enter_container_select_mode()),
    EzKey("M-<escape>", lazy.layout.exit_container_select_mode()),
    EzKey("M-o", lazy.layout.select_container_outer()),
    EzKey("M-i", lazy.layout.select_container_inner()),
    #
    KeyChord(
        [mod],
        "t",
        [
            # Spawn new windows in a new root-level tabs,
            EzKey("M-A-<Return>", lazy.spawn(terminal)),
            EzKey("M-A-<space>", lazy.spawn(launcher)),
            # as a sibling of the current tab,
            EzKey("M-<return>", lazy.layout.spawn_tab(terminal)),
            EzKey("M-<space>", lazy.layout.spawn_tab(launcher)),
            # or as a nested child in the current tab.
            EzKey("S-<return>", lazy.layout.spawn_tab(terminal, new_level=True)),
            EzKey("S-<space>", lazy.layout.spawn_tab(launcher, new_level=True)),
            #
            EzKey("r", lazy.layout.rename_tab()),
            EzKey("b", lazy.layout.pull_out_to_tab()),
            #
            EzKey("h", lazy.layout.prev_tab()),
            EzKey("l", lazy.layout.next_tab()),
            #
            # Normalize window sizes
            EzKey("n", lazy.layout.normalize_tab()),
            EzKey("S-n", lazy.layout.normalize_tab(recurse=True)),
            EzKey("M-S-n", lazy.layout.normalize_all()),
        ],
    ),
    KeyChord(
        [mod],
        "a",
        [
            # Pull windows out of tabs
            EzKey("e", lazy.layout.pull_out(position="next")),
            EzKey("C-e", lazy.layout.pull_out()),
            #
            # Directional commands to move window inside neighbor space.
            EzKey("h", lazy.layout.push_in("left")),
            EzKey("l", lazy.layout.push_in("right")),
            EzKey("j", lazy.layout.push_in("down")),
            EzKey("k", lazy.layout.push_in("up")),
            EzKey("S-h", lazy.layout.push_in("left", dest_selection="mru_deepest")),
            EzKey("S-l", lazy.layout.push_in("right", dest_selection="mru_deepest")),
            EzKey("S-j", lazy.layout.push_in("down", dest_selection="mru_deepest")),
            EzKey("S-k", lazy.layout.push_in("up", dest_selection="mru_deepest")),
            #
            # Directional commands to merge windows with their neighbor into subtabs.
            EzKey("M-h", lazy.layout.merge_to_subtab("left")),
            EzKey("M-l", lazy.layout.merge_to_subtab("right")),
            EzKey("M-j", lazy.layout.merge_to_subtab("down")),
            EzKey("M-k", lazy.layout.merge_to_subtab("up")),
            #
            # Merge entire tabs with each other as splits
            EzKey("M-S-h", lazy.layout.merge_tabs("previous", "x")),
            EzKey("M-S-l", lazy.layout.merge_tabs("next", "x")),
            EzKey("M-<left>", lazy.layout.merge_tabs("previous", "y")),
            EzKey("M-<right>", lazy.layout.merge_tabs("next", "y")),
            #
            # Normalize windows
            EzKey("n", lazy.layout.normalize()),
            EzKey("S-n", lazy.layout.normalize(recurse=True)),
        ],
    ),
    # KeyChord([mod], "g", []),
    # KeyChord(hyper, "a", []),
]

# Workspace
for i in groups:
    keys.extend(
        [
            EzKey(
                f"M-A-{i.name}",
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
