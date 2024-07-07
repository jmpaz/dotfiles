from os.path import expanduser
from sys import path

from libqtile import qtile
from libqtile.config import Click, Drag, Key
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from .groups import groups

mod = "mod4"
alt = "mod1"
terminal = "kitty"
launcher = "rofi -modi drun,run -show drun"


keys = [
    # Switch focus between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([alt], "space", lazy.layout.next(), desc="Move window focus to other window"),
    ########
    ## Move windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Shuffle window up"),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Shuffle window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Shuffle window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Shuffle window up"),
    ########
    ## Grow windows
    Key(
        [mod, "control"],
        "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        desc="Increase active window size.",
    ),
    Key(
        [mod, "control"],
        "Up",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        desc="Increase active window size.",
    ),
    Key(
        [mod, "control"],
        "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        desc="Decrease active window size.",
    ),
    Key(
        [mod, "control"],
        "Down",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        desc="Decrease active window size.",
    ),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key(
        [mod], "r", lazy.layout.reset(), desc="Reset the sizes of all window in group."
    ),
    ########
    ## Monitor focus
    Key([mod], "i", lazy.to_screen(0), desc="Keyboard focus to monitor 1"),
    Key([mod], "o", lazy.to_screen(1), desc="Keyboard focus to monitor 2"),
    Key([mod], "period", lazy.next_screen(), desc="Move focus to next monitor"),
    Key([mod], "comma", lazy.prev_screen(), desc="Move focus to prev monitor"),
    Key([alt], "Tab", lazy.screen.next_group(), desc="Move to next group."),
    Key(
        [alt, "shift"],
        "Tab",
        lazy.screen.prev_group(),
        desc="Move to previous group.",
    ),
    ########
    ## Layout manipulation
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [alt],
        "f",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    ########
    ## Qtile
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control", "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    ########
    ## Applications
    Key(
        [mod, "shift"], "Return", lazy.spawn(guess_terminal()), desc="Fallback terminal"
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "Space", lazy.spawn(launcher), desc="Launch rofi"),
    Key([mod, "shift"], "f", lazy.spawn("firefox"), desc="Launch web browser"),
]


# Workspace
for i in groups:
    keys.extend(
        [
            # mod1 + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + group number = move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name),
                desc="move focused window to group {}".format(i.name),
            ),
        ]
    )


# Scratchpad
keys.extend(
    [
        Key([mod, alt], "Return", lazy.group["scratchpad"].dropdown_toggle("term")),
        Key([mod, alt], "v", lazy.group["scratchpad"].dropdown_toggle("volume")),
    ]
)


# Media keys
keys.extend(
    [
        Key(
            [],
            "XF86AudioRaiseVolume",
            lazy.spawn("pactl -- set-sink-volume 0 +5%"),
            desc="Volume Up",
        ),
        Key(
            [],
            "XF86AudioLowerVolume",
            lazy.spawn("pactl -- set-sink-volume 0 -5%"),
            desc="Volume Down",
        ),
        Key(
            [],
            "XF86AudioMute",
            lazy.spawn("pactl set-sink-mute 0 toggle"),
            desc="Toggle Mute",
        ),
        Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/Pause"),
        Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Next Song"),
        Key(
            [], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Previous Song"
        ),
        Key([], "XF86AudioStop", lazy.spawn("playerctl stop"), desc="Stop music"),
        Key(
            [],
            "XF86MonBrightnessUp",
            lazy.spawn("brightnessctl set 5%+"),
            desc="Increase brightness",
        ),
        Key(
            [],
            "XF86MonBrightnessDown",
            lazy.spawn("brightnessctl set 5%-"),
            desc="Decrease brightness",
        ),
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
