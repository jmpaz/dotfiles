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
    # Switch focus between windows
    # EzKey("M-h", lazy.layout.left(), desc="Move focus to left"),
    # EzKey("M-l", lazy.layout.right(), desc="Move focus to right"),
    # EzKey("M-j", lazy.layout.down(), desc="Move focus down"),
    # EzKey("M-k", lazy.layout.up(), desc="Move focus up"),
    EzKey("A-<space>", lazy.layout.next(), desc="Move window focus to other window"),
    ########
    ## Move windows
    # EzKey("M-S-h", lazy.layout.shuffle_left(), desc="Shuffle window up"),
    # EzKey("M-S-l", lazy.layout.shuffle_right(), desc="Shuffle window to the right"),
    # EzKey("M-S-j", lazy.layout.shuffle_down(), desc="Shuffle window down"),
    # EzKey("M-S-k", lazy.layout.shuffle_up(), desc="Shuffle window up"),
    ########
    ## Grow windows
    # EzKey(
    #     "M-C-h",
    #     lazy.layout.grow_left(),
    #     lazy.layout.shrink(),
    #     desc="Decrease active window size.",
    # ),
    # EzKey(
    #     "M-C-l",
    #     lazy.layout.grow_right(),
    #     lazy.layout.grow(),
    #     desc="Increase active window size.",
    # ),
    # EzKey(
    #     "M-C-j",
    #     lazy.layout.grow_down(),
    #     lazy.layout.shrink(),
    #     lazy.layout.increase_nmaster(),
    #     desc="Decrease active window size.",
    # ),
    # EzKey(
    #     "M-C-k",
    #     lazy.layout.grow_up(),
    #     lazy.layout.grow(),
    #     lazy.layout.decrease_nmaster(),
    #     desc="Increase active window size.",
    # ),
    EzKey("M-n", lazy.layout.normalize(), desc="Reset all window sizes"),
    EzKey("M-r", lazy.layout.reset(), desc="Reset the sizes of all window in group."),
    ########
    ## Monitor focus
    # EzKey("M-A-1", lazy.to_screen(0), desc="Keyboard focus to monitor 1"),
    # EzKey("M-A-<grave>", lazy.to_screen(1), desc="Keyboard focus to monitor 2"),
    EzKey("M-<period>", lazy.next_screen(), desc="Move focus to next monitor"),
    EzKey(
        "M-S-<period>",
        lazy.move_window_to_next_screen(),
        desc="Move window to next monitor",
    ),
    EzKey("M-<comma>", lazy.prev_screen(), desc="Move focus to prev monitor"),
    EzKey("M-<tab>", lazy.screen.next_group(), desc="Move to next group."),
    EzKey("M-S-<tab>", lazy.screen.prev_group(), desc="Move to previous group."),
    ########
    ## Layout
    EzKey(
        "M-S-<Return>",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    EzKey("M-S-q", lazy.window.kill(), desc="Kill focused window"),
    # EzKey("M-f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    EzKey(
        "M-f", lazy.next_layout(), desc="Toggle fullscreen for the current group"
    ),  # necessary for bonsai
    EzKey(
        "A-f",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    ########
    ## Bonsai
    # Spawn a new terminal at the current tab level
    EzKey("M-<backslash>", lazy.layout.spawn_split(terminal, "x")),
    EzKey("M-<minus>", lazy.layout.spawn_split(terminal, "y")),
    EzKey("M-S-<minus>", lazy.layout.spawn_split(terminal, "y", position="previous")),
    EzKey(
        "M-S-<backslash>", lazy.layout.spawn_split(terminal, "x", position="previous")
    ),
    EzKey("M-t", lazy.layout.spawn_tab(terminal)),
    EzKey("M-S-t", lazy.layout.spawn_tab(terminal, new_level=True)),
    #
    # Motions to move focus. The names are compatible with built-in layouts.
    EzKey("M-h", lazy.layout.left()),
    EzKey("M-l", lazy.layout.right()),
    EzKey("M-k", lazy.layout.up()),
    EzKey("M-j", lazy.layout.down()),
    EzKey("M-p", lazy.layout.prev_tab()),
    EzKey("M-n", lazy.layout.next_tab()),
    #
    # Precise motions to move directly to specific tabs at the nearest tab level
    EzKey("M-A-1", lazy.layout.focus_nth_tab(1, level=1)),
    EzKey("M-A-2", lazy.layout.focus_nth_tab(2, level=1)),
    EzKey("M-A-3", lazy.layout.focus_nth_tab(3, level=1)),
    EzKey("M-A-4", lazy.layout.focus_nth_tab(4, level=1)),
    EzKey("M-A-5", lazy.layout.focus_nth_tab(5, level=1)),
    EzKey("M-A-6", lazy.layout.focus_nth_tab(6, level=1)),
    EzKey("M-A-7", lazy.layout.focus_nth_tab(7, level=1)),
    EzKey("M-A-8", lazy.layout.focus_nth_tab(8, level=1)),
    EzKey("M-A-9", lazy.layout.focus_nth_tab(9, level=1)),
    EzKey("M-A-0", lazy.layout.focus_nth_tab(10, level=1)),
    #
    # Resize operations
    EzKey("M-C-h", lazy.layout.resize("left", 100)),
    EzKey("M-C-l", lazy.layout.resize("right", 100)),
    EzKey("M-C-k", lazy.layout.resize("up", 100)),
    EzKey("M-C-j", lazy.layout.resize("down", 100)),
    #
    # Swap windows/tabs with neighbors
    EzKey("M-S-h", lazy.layout.swap("left")),
    EzKey("M-S-l", lazy.layout.swap("right")),
    EzKey("M-S-k", lazy.layout.swap("up")),
    EzKey("M-S-j", lazy.layout.swap("down")),
    EzKey("A-S-p", lazy.layout.swap_tabs("previous")),
    EzKey("A-S-n", lazy.layout.swap_tabs("next")),
    #
    # Manipulate selections after entering container-select mode
    EzKey("M-o", lazy.layout.select_container_outer()),
    EzKey("M-i", lazy.layout.select_container_inner()),
    #
    KeyChord(
        [mod],
        "t",
        [
            EzKey("n", lazy.layout.spawn_tab(terminal)),
            EzKey("S-n", lazy.layout.spawn_tab(terminal, new_level=True)),
            EzKey("<space>", lazy.layout.spawn_tab(launcher)),
            EzKey("S-<space>", lazy.layout.spawn_tab(launcher, new_level=True)),
        ],
    ),
    KeyChord(
        [mod],
        "a",
        [
            EzKey("<minus>", lazy.layout.spawn_split(launcher, "y")),
            EzKey(
                "S-<minus>", lazy.layout.spawn_split(launcher, "y", position="previous")
            ),
            EzKey("<backslash>", lazy.layout.spawn_split(launcher, "x")),
            EzKey(
                "S-<backslash>",
                lazy.layout.spawn_split(launcher, "x", position="previous"),
            ),
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
            #
            # Toggle container-selection mode to split/tab over containers of
            # multiple windows. Manipulate using select_container_outer()/select_container_inner()
            EzKey("v", lazy.layout.toggle_container_select_mode()),
            EzKey("o", lazy.layout.pull_out()),
            EzKey("u", lazy.layout.pull_out_to_tab()),
            EzKey("r", lazy.layout.rename_tab()),
            # Directional commands to merge windows with their neighbor into subtabs.
            KeyChord(
                [],
                "m",
                [
                    EzKey("h", lazy.layout.merge_to_subtab("left")),
                    EzKey("l", lazy.layout.merge_to_subtab("right")),
                    EzKey("j", lazy.layout.merge_to_subtab("down")),
                    EzKey("k", lazy.layout.merge_to_subtab("up")),
                    # Merge entire tabs with each other as splits
                    EzKey("S-h", lazy.layout.merge_tabs("previous")),
                    EzKey("S-l", lazy.layout.merge_tabs("next")),
                ],
            ),
            # Directional commands for push_in() to move window inside neighbor space.
            KeyChord(
                [],
                "i",
                [
                    EzKey("j", lazy.layout.push_in("down")),
                    EzKey("k", lazy.layout.push_in("up")),
                    EzKey("h", lazy.layout.push_in("left")),
                    EzKey("l", lazy.layout.push_in("right")),
                    # It's nice to be able to push directly into the deepest
                    # neighbor node when desired. The default bindings above
                    # will have us push into the largest neighbor container.
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
                ],
            ),
        ],
    ),
    ########
    ## Qtile
    EzKey("M-C-r", lazy.reload_config(), desc="Reload the config"),
    EzKey("M-C-S-q", lazy.shutdown(), desc="Shutdown Qtile"),
    ########
    ## Applications
    EzKey("M-<Return>", lazy.spawn(terminal), desc="Launch terminal"),
    EzKey("M-S-<Return>", lazy.spawn(guess_terminal()), desc="Fallback terminal"),
    EzKey("M-<space>", lazy.spawn(launcher), desc="Launch rofi"),
    EzKey("M-S-f", lazy.spawn("firefox"), desc="Launch web browser"),
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
        EzKey("M-C-<grave>", lazy.group["scratchpad"].dropdown_toggle("term")),
        EzKey("M-A-v", lazy.group["scratchpad"].dropdown_toggle("volume")),
        EzKey("M-A-f", lazy.group["scratchpad"].dropdown_toggle("files")),
        EzKey("M-A-p", lazy.group["scratchpad"].dropdown_toggle("bitwarden")),
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
