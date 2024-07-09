from os.path import expanduser
from sys import path

from libqtile import config, qtile
from libqtile.config import Click, Drag, EzKey, Key
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from .groups import groups

mod = "mod4"
alt = "mod1"
terminal = "kitty"
launcher = "rofi -modi drun,run -show drun"


keys = [
    # Switch focus between windows
    EzKey("M-h", lazy.layout.left(), desc="Move focus to left"),
    EzKey("M-l", lazy.layout.right(), desc="Move focus to right"),
    EzKey("M-j", lazy.layout.down(), desc="Move focus down"),
    EzKey("M-k", lazy.layout.up(), desc="Move focus up"),
    EzKey("A-<space>", lazy.layout.next(), desc="Move window focus to other window"),
    ########
    ## Move windows
    EzKey("M-S-h", lazy.layout.shuffle_left(), desc="Shuffle window up"),
    EzKey("M-S-l", lazy.layout.shuffle_right(), desc="Shuffle window to the right"),
    EzKey("M-S-j", lazy.layout.shuffle_down(), desc="Shuffle window down"),
    EzKey("M-S-k", lazy.layout.shuffle_up(), desc="Shuffle window up"),
    ########
    ## Grow windows
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
    EzKey("M-n", lazy.layout.normalize(), desc="Reset all window sizes"),
    EzKey("M-r", lazy.layout.reset(), desc="Reset the sizes of all window in group."),
    ########
    ## Monitor focus
    EzKey("M-A-1", lazy.to_screen(0), desc="Keyboard focus to monitor 1"),
    EzKey("M-A-<grave>", lazy.to_screen(1), desc="Keyboard focus to monitor 2"),
    EzKey("M-A-<period>", lazy.next_screen(), desc="Move focus to next monitor"),
    EzKey("M-A-<comma>", lazy.prev_screen(), desc="Move focus to prev monitor"),
    EzKey("M-<tab>", lazy.screen.next_group(), desc="Move to next group."),
    EzKey("M-S-<tab>", lazy.screen.prev_group(), desc="Move to previous group."),
    ########
    ## Layout
    EzKey(
        "M-S-<Return>",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    EzKey("A-<tab>", lazy.next_layout(), desc="Toggle between layouts"),
    EzKey("M-S-q", lazy.window.kill(), desc="Kill focused window"),
    EzKey(
        "M-f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    EzKey(
        "A-f",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
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
