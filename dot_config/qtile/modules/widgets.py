import subprocess

from qtile_bonsai import BonsaiBar
from qtile_extras import widget
from qtile_extras.widget.decorations import RectDecoration

from libqtile import bar, qtile
from libqtile.lazy import lazy

from .colors import colors

widget_defaults = dict(font="Sauce Code Pro Nerd Font", fontsize=14)
dark_widgets = {
    "decorations": [
        RectDecoration(
            colour=colors["focused_background"],
            filled=True,
            radius=10,
            padding_y=4,
            group=True,
        )
    ]
}
light_widgets = {
    "decorations": [
        RectDecoration(
            colour=colors["unfocused_bg"],
            filled=True,
            radius=10,
            padding_y=4,
            group=True,
        )
    ]
}
mid_widgets = {
    "decorations": [
        RectDecoration(
            foreground=colors["focused_text"],
            colour=colors["focused_background"],
            filled=True,
            radius=10,
            padding_y=4,
            group=True,
        )
    ]
}


def load_widgets(display):
    widgets_list = [
        ########
        ### Left Side
        # widget.Prompt(**widget_defaults, **mid_widgets),
        # tabs
        BonsaiBar(
            **{
                "length": 500,
                "tab.width": 30,
                "tab.fg_color": colors["unfocused_text"],
                "tab.bg_color": colors["background"],
                # "tab.active.fg_color": colors["active_tab_fg_light"],
                "tab.active.fg_color": colors["active_tab_fg"],
                "tab.active.bg_color": colors["active_tab_bg"],
                "container_select_mode.indicator.bg_color": colors["color6"],
                "font_family": "Sauce Code Pro Nerd Font",
            }
        ),
        ########
        ## Middle
        widget.Spacer(),
        widget.GroupBox(
            active=colors["focused_text"],
            borderwidth=2,
            disable_drag=True,
            hide_unused=False,
            highlight_color=[colors["background"], colors["background"]],
            highlight_method="line",
            inactive=colors["unfocused_text"],
            this_current_screen_border=colors["focused_indicator"],
            this_screen_border=colors["focused_border"],
            other_current_screen_border=colors["focused_inactive_border"],
            other_screen_border=colors["unfocused_border"],
            urgent_method="block",
            urgent_border=colors["urgent_border"],
            urgent_text=colors["urgent_text"],
            use_mouse_wheel=True,
            **dark_widgets,
            **widget_defaults,
        ),
        ########
        ### Right Side
        widget.Spacer(),
        ## Performance
        *performance_widgets(),
        widget.Sep(
            linewidth=0,
            padding=10,
        ),
        ## Volume
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        widget.PulseVolume(
            fmt="󰕾 {}",  # Nerd Fonts icon for volume
            bar_width=50,  # Width of the volume bar
            bar_filled_color="2f343f",  # Color of the filled part of the bar
            bar_unfilled_color="4b5162",  # Color of the unfilled part of the bar
            get_volume_command="pamixer --get-volume",
            foreground=colors["focused_text"],
            **widget_defaults,
            **mid_widgets,
        ),
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        #
        ## Date/Time
        widget.Sep(
            linewidth=0,
            padding=10,
        ),
        widget.Clock(
            format=" %d %b | %I:%M%P ",
            mouse_callbacks={
                "Button1": lazy.spawn("wlogout"),
            },
            foreground=colors["focused_text"],
            **widget_defaults,
            **mid_widgets,
        ),
        widget.Sep(linewidth=0, padding=7),
    ]

    return widgets_list


def performance_widgets():
    def create_separator(padding=15, size_percent=60):
        return widget.Sep(
            foreground=colors["unfocused_text"],
            padding=padding,
            size_percent=size_percent,
            **mid_widgets,
        )

    return [
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        # Memory
        widget.TextBox(
            text="",
            font="FontAwesome6Free",
            fontsize=12,
            foreground=colors["focused_text"],
            padding=5,
            **mid_widgets,
        ),
        widget.Memory(
            foreground=colors["focused_text"],
            format="{MemPercent}%",
            measure_mem="M",
            padding=5,
            **widget_defaults,
            **mid_widgets,
        ),
        create_separator(),
        # CPU Usage
        widget.TextBox(
            text="",
            font="FontAwesome6Free",
            fontsize=12,
            foreground=colors["focused_text"],
            padding=5,
            **mid_widgets,
        ),
        widget.CPU(
            foreground=colors["focused_text"],
            format="{load_percent}%",
            padding=5,
            **widget_defaults,
            **mid_widgets,
        ),
        create_separator(),
        # CPU Temperature
        widget.TextBox(
            text="󰔏",
            fontsize=15,
            foreground=colors["focused_text"],
            padding=5,
            **mid_widgets,
        ),
        widget.ThermalSensor(
            foreground=colors["focused_text"], **widget_defaults, **mid_widgets
        ),
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
    ]


def apps_tray_widgets():
    return [
        widget.Sep(
            linewidth=0,
            padding=10,
        ),
        # chat
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        widget.TextBox(
            text="󰻞",
            mouse_callbacks={
                "Button1": lazy.spawn("google-chrome-stable --app=https://claude.ai/"),
            },
            **mid_widgets,
            **widget_defaults,
        ),
        # files
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        widget.TextBox(
            text="",
            mouse_callbacks={
                "Button1": lazy.spawn("nemo"),
            },
            **widget_defaults,
            **mid_widgets,
        ),
        # bluetooth
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        widget.TextBox(
            text="",
            mouse_callbacks={
                "Button1": lazy.spawn("blueman-manager"),
            },
            **mid_widgets,
            **widget_defaults,
        ),
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
    ]
