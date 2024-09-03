from os.path import expanduser
from sys import path
from typing import Union

from libqtile import config, qtile
from libqtile.config import Click, Drag, EzConfig, EzKey, EzKeyChord, Key, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from .groups import groups
from .platform import get_number_of_screens, is_wayland
from .theme import set_wallpaper, initialize_wallpapers

num_screens = get_number_of_screens()
previous_layouts = {0: None, 1: None}


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


def smart_move(direction):
    """Returns a layout-dependent function for moving a window in the given direction."""

    @lazy.function
    def _inner(qtile):
        layout = qtile.current_layout.name
        if layout == "plasma":
            getattr(qtile.current_layout, f"move_{direction}")()
        else:
            getattr(qtile.current_layout, f"shuffle_{direction}")()

    return _inner


@lazy.function
def smart_toggle(qtile):
    layout = qtile.current_layout
    layout_name = layout.name

    if layout_name == "columns":
        layout.toggle_split()
    elif layout_name == "verticaltile":
        if layout.maximized:
            layout.normalize()
        else:
            layout.maximize()


@lazy.function
def toggle_max_layout(qtile):
    current_screen = qtile.current_screen.index
    current_group = qtile.current_group
    current_layout = current_group.layout.name

    if current_layout == "max":
        if previous_layouts[current_screen]:
            current_group.setlayout(previous_layouts[current_screen])
            previous_layouts[current_screen] = None
    else:
        previous_layouts[current_screen] = current_layout
        current_group.setlayout("max")


@lazy.function
def system_control(qtile, action, device, step=5):
    if device == "volume":
        if is_wayland():
            if action == "mute":
                return qtile.cmd_spawn("pulsemixer --toggle-mute")
            elif action == "+":
                return qtile.cmd_spawn(f"pulsemixer --change-volume +{step}")
            else:  # action == "-"
                return qtile.cmd_spawn(f"pulsemixer --change-volume -{step}")
        else:
            if action == "mute":
                return qtile.cmd_spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
            else:
                return qtile.cmd_spawn(f"pactl -- set-sink-volume @DEFAULT_SINK@ {action}{step}%")
    elif device == "brightness":
        if is_wayland():
            return qtile.cmd_spawn(f"light -{action} {step}")
        else:
            return qtile.cmd_spawn(f"xbacklight -{action} {step}")


def go_to_group(name: str):
    def _inner(qtile):
        if len(qtile.screens) == 1:
            qtile.groups_map[name].toscreen()
            return

        if name in "123456789":
            qtile.focus_screen(0)
            qtile.groups_map[name].toscreen()
        else:
            qtile.focus_screen(1)
            qtile.groups_map[name].toscreen()

    return _inner


def go_to_group_and_move_window(name: str):
    def _inner(qtile):
        if len(qtile.screens) == 1:
            qtile.current_window.togroup(name, switch_group=False)
            return

        if name in "123456789":
            qtile.current_window.togroup(name, switch_group=False)
            qtile.focus_screen(0)
        else:
            qtile.current_window.togroup(name, switch_group=False)
            qtile.focus_screen(1)

    return _inner


mod = "mod4"
alt = "mod1"
hyper = [mod, "shift", "control", alt]
hyper_str = "M-S-C-A"

terminal = "alacritty"
launcher = "rofi -modi drun,run -show drun" if not is_wayland() else "fuzzel"


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
    EzKey("M-m", toggle_max_layout, desc="Maximize/restore"),
    EzKey(
        "A-f",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    EzKey("M-A-<space>", smart_toggle, desc="Expand focused window"),
    ## Motions
    # Focus
    EzKey("M-h", lazy.layout.left()),
    EzKey("M-l", lazy.layout.right()),
    EzKey("M-k", lazy.layout.up()),
    EzKey("M-j", lazy.layout.down()),
    # Move
    EzKey("M-S-h", smart_move("left")),
    EzKey("M-S-l", smart_move("right")),
    EzKey("M-S-k", smart_move("up")),
    EzKey("M-S-j", smart_move("down")),
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
        "M-A-n",
        lazy.layout.reset_size(),
        lazy.layout.normalize(),
        desc="Reset all window sizes",
    ),
    EzKey("M-A-r", lazy.layout.reset(), desc="Reset the sizes of all windows in group."),
    #
    # Manage groups/monitors
    EzKey("M-<tab>", lazy.screen.next_group(), desc="Switch to next group"),
    EzKey("M-S-<tab>", lazy.screen.prev_group(), desc="Switch to previous group"),
    EzKey("M-n", lazy.screen.next_group(), desc="Switch to next group"),
    EzKey("M-p", lazy.screen.prev_group(), desc="Switch to next group"),
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
    KeyChord(
        hyper,
        "w",
        [
            EzKey("n", lazy.function(set_wallpaper, cycle_direction="next")),
            EzKey("p", lazy.function(set_wallpaper, cycle_direction="prev")),
            EzKey("r", lazy.function(set_wallpaper, cycle_direction="random")),
            EzKey("i", lazy.function(initialize_wallpapers)),
        ],
    ),
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
monad_keys = [
    EzKey("M-A-f", lazy.layout.flip()),
]
keys.extend(plasma_keys)
keys.extend(monad_keys)

# Workspace
for i in groups:
    if i.name in "123456789":
        keys.extend(
            [
                Key([mod], i.name, lazy.function(go_to_group(i.name))),
                Key([mod, "shift"], i.name, lazy.function(go_to_group_and_move_window(i.name))),
            ]
        )
    elif i.name in ["I", "II", "III", "IV", "V"] and num_screens > 1:
        index = ["I", "II", "III", "IV", "V"].index(i.name)
        keys.extend(
            [
                Key([mod, "mod1"], str(index + 1), lazy.function(go_to_group(i.name))),
                Key(
                    [mod, "mod1", "shift"],
                    str(index + 1),
                    lazy.function(go_to_group_and_move_window(i.name)),
                ),
            ]
        )

# Scratchpad
keys.extend(
    [
        # KeyChord([mod], "s", []),
        EzKey("C-M-<grave>", lazy.group["scratchpad"].dropdown_toggle("term")),
        EzKey("C-M-a", lazy.group["scratchpad"].dropdown_toggle("audio")),
        EzKey("C-M-n", lazy.group["scratchpad"].dropdown_toggle("obsidian")),
        EzKey("C-M-o", lazy.group["scratchpad"].dropdown_toggle("obs")),
        EzKey("C-M-f", lazy.group["scratchpad"].dropdown_toggle("files")),
    ]
)

# System control
keys.extend(
    [
        EzKey(
            "<XF86AudioRaiseVolume>",
            system_control(action="+", device="volume"),
            desc="Volume Up",
        ),
        EzKey(
            "S-<XF86AudioRaiseVolume>",
            system_control(action="+", device="volume", step=10),
            desc="Volume Up (2x)",
        ),
        EzKey(
            "<XF86AudioLowerVolume>",
            system_control(action="-", device="volume"),
            desc="Volume Down",
        ),
        EzKey(
            "S-<XF86AudioLowerVolume>",
            system_control(action="-", device="volume", step=10),
            desc="Volume Down (2x)",
        ),
        EzKey(
            "<XF86AudioMute>", system_control(action="mute", device="volume"), desc="Toggle Mute"
        ),
        EzKey(
            "<XF86MonBrightnessUp>",
            system_control(action="A", device="brightness", step=1),
            desc="Brightness Up",
        ),
        EzKey(
            "<XF86MonBrightnessDown>",
            system_control(action="U", device="brightness", step=1),
            desc="Brightness Down",
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
        lazy.window.set_position(),
        start=lazy.window.get_position(),
    ),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]
