import subprocess

from qtile_extras import widget
from qtile_extras.widget.decorations import RectDecoration

from libqtile import bar, qtile
from libqtile.lazy import lazy

from .colors import colors
from .platform import is_wayland

defaults = dict(font="Sauce Code Pro Nerd Font", fontsize=14)
decorations = {
    "decorations": [
        RectDecoration(
            foreground=colors["focused_text"],
            colour=colors["focused_background"],
            filled=True,
            radius=10,
            padding_y=4,
            group=True,
        )
    ],
}


def create_separator(padding=15, size_percent=60):
    return widget.Sep(
        foreground=colors["unfocused_text"],
        padding=padding,
        size_percent=size_percent,
        **decorations,
    )


def load_widgets(display):
    def left():
        return [
            # widget.Prompt(**widget_defaults, **mid_widgets),
            # layout
            widget.Sep(linewidth=0, padding=7),
            widget.Sep(linewidth=0, padding=10, **decorations),
            # widget.CurrentLayoutIcon(
            #     scale=0.3,
            #     **defaults,
            #     **decorations,
            # ),
            widget.CurrentLayout(
                foreground=colors["focused_text"],
                **defaults,
                **decorations,
                fmt="<b>{}</b>",
            ),
            create_separator(),
            widget.Sep(linewidth=0, padding=2, **decorations),
            # window name
            widget.WindowName(
                max_chars=0,
                empty_group_string="desktop",
                width=275,
                scroll=True,
                format="{name}",
                foreground=colors["focused_text"],
                **defaults,
                **decorations,
            ),
            widget.Sep(linewidth=0, padding=10, **decorations),
        ]

    def center(display):
        primary_groups = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
        secondary_groups = ["I", "II", "III", "IV", "V"]

        return [
            widget.Spacer(),
            widget.GroupBox(
                **defaults,
                **{
                    "decorations": [
                        RectDecoration(
                            # foreground=colors["focused_text"],
                            colour=colors["focused_background"],
                            radius=7,
                            filled=True,
                            padding_y=3,
                            padding_x=3,
                        )
                    ],
                    "padding": 12,
                },
                borderwidth=2,
                margin_x=6,
                disable_drag=True,
                rounded=False,
                hide_unused=False,
                visible_groups=primary_groups if display == 0 else secondary_groups,
                # highlight
                highlight_method="line",
                highlight_color="#00000000",  # transparent
                active=colors["focused_text"],
                inactive=colors["unfocused_text"],
                # indicator
                this_current_screen_border=colors["focused_indicator"],
                this_screen_border=colors["focused_border"],
                other_current_screen_border=colors["focused_inactive_border"],
                other_screen_border=colors["unfocused_border"],
                # urgent
                urgent_method="block",
                urgent_border=colors["urgent_border"],
                urgent_text=colors["urgent_text"],
            ),
        ]

    def right():
        return [
            widget.Spacer(),
            ## Performance
            *performance_widgets(),
            widget.Sep(linewidth=0, padding=10),
            ## Volume
            widget.Sep(linewidth=0, padding=10, **decorations),
            volume_widget()[0],
            widget.Sep(linewidth=0, padding=10, **decorations),
            #
            ## Date/Time
            widget.Sep(
                linewidth=0,
                padding=10,
            ),
            widget.Clock(
                format=" %d %b | <b>%-I:%M%P</b> ",
                mouse_callbacks={
                    "Button1": lazy.spawn("wlogout"),
                },
                foreground=colors["focused_text"],
                **defaults,
                **decorations,
            ),
            widget.Sep(linewidth=0, padding=7),
        ]

    return left() + center(display) + right()


def volume_widget():
    if not is_wayland():
        return [
            widget.PulseVolume(
                fmt="󰕾 {}",  # Nerd Fonts icon for volume
                bar_width=50,  # Width of the volume bar
                bar_filled_color="2f343f",  # Color of the filled part of the bar
                bar_unfilled_color="4b5162",  # Color of the unfilled part of the bar
                get_volume_command="pamixer --get-volume",
                foreground=colors["focused_text"],
                **defaults,
                **decorations,
            ),
        ]
    else:
        return [
            widget.GenPollText(
                func=lambda: subprocess.check_output("pamixer --get-volume", shell=True)
                .decode()
                .strip(),
                update_interval=0.2,
                format="󰕾 {}%",
                foreground=colors["focused_text"],
                **defaults,
                **decorations,
            ),
        ]


def performance_widgets():
    return [
        widget.Sep(linewidth=0, padding=10, **decorations),
        # Memory
        widget.TextBox(
            text="",
            font="FontAwesome6Free",
            fontsize=12,
            foreground=colors["focused_text"],
            padding=5,
            **decorations,
        ),
        widget.Memory(
            foreground=colors["focused_text"],
            format="{MemPercent}%",
            measure_mem="M",
            padding=5,
            **defaults,
            **decorations,
        ),
        create_separator(),
        # CPU Usage
        widget.TextBox(
            text="",
            font="FontAwesome6Free",
            fontsize=12,
            foreground=colors["focused_text"],
            padding=5,
            **decorations,
        ),
        widget.CPU(
            foreground=colors["focused_text"],
            format="{load_percent}%",
            padding=5,
            **defaults,
            **decorations,
        ),
        create_separator(),
        # CPU Temperature
        widget.TextBox(
            text="󰔏",
            fontsize=15,
            foreground=colors["focused_text"],
            padding=5,
            **decorations,
        ),
        widget.ThermalSensor(
            foreground=colors["focused_text"],
            **defaults,
            **decorations,
            format="{temp:.1f}°",
        ),
        widget.TextBox(
            text="• ", foreground=colors["focused_text"], padding=5, **decorations
        ),
        widget.NvidiaSensors(
            foreground=colors["focused_text"],
            **defaults,
            **decorations,
            gpu_bus_id="01:00.0",
            format="{temp}°",
        ),
        widget.TextBox(
            text="/", foreground=colors["focused_text"], padding=5, **decorations
        ),
        widget.NvidiaSensors(
            foreground=colors["focused_text"],
            **defaults,
            **decorations,
            gpu_bus_id="02:00.0",
        ),
        widget.Sep(linewidth=0, padding=10, **decorations),
    ]


def apps_tray_widgets():
    return [
        widget.Sep(
            linewidth=0,
            padding=10,
        ),
        # chat
        widget.Sep(linewidth=0, padding=10, **decorations),
        widget.TextBox(
            text="󰻞",
            mouse_callbacks={
                "Button1": lazy.spawn("google-chrome-stable --app=https://claude.ai/"),
            },
            **decorations,
            **defaults,
        ),
        # files
        widget.Sep(linewidth=0, padding=10, **decorations),
        widget.TextBox(
            text="",
            mouse_callbacks={"Button1": lazy.spawn("nemo")},
            **defaults,
            **decorations,
        ),
        # bluetooth
        widget.Sep(linewidth=0, padding=10, **decorations),
        widget.TextBox(
            text="",
            mouse_callbacks={"Button1": lazy.spawn("blueman-manager")},
            **decorations,
            **defaults,
        ),
        widget.Sep(linewidth=0, padding=10, **decorations),
    ]
