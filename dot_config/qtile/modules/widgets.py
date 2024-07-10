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
        # widget.Sep(linewidth=0, padding=7),
        # widget.Sep(linewidth=0, **mid_widgets),
        # widget.CurrentLayout(**widget_defaults, **mid_widgets),
        # widget.CurrentLayoutIcon(**widget_defaults, **mid_widgets),
        # widget.Sep(linewidth=0, **mid_widgets),
        BonsaiBar(
            **{
                "length": 500,
                "tab.width": 30,
                "tab.bg_color": colors["background"],
                "tab.fg_color": colors["unfocused_text"],
                "tab.active.bg_color": colors["focused_indicator"],
                "tab.active.fg_color": colors["color15"],
                "font_family": "Sauce Code Pro Nerd Font",
            }
        ),
        widget.Sep(linewidth=0, **mid_widgets),
        # ## Performance
        # # Memory
        # widget.TextBox(
        #     text="",
        #     font="FontAwesome6Free",
        #     fontsize=12,
        #     foreground=colors["focused_text"],
        #     margin=0,
        #     padding=5,
        #     **light_widgets,
        # ),
        # widget.Memory(
        #     foreground=colors["focused_text"],
        #     format="{MemPercent}%",
        #     measure_mem="M",
        #     margin=0,
        #     padding=0,
        #     **widget_defaults,
        #     **light_widgets,
        # ),
        # widget.Sep(
        #     foreground=colors["focused_text"],
        #     padding=10,
        #     size_percent=60,
        #     **light_widgets,
        # ),
        # # CPU usage
        # widget.TextBox(
        #     text="",
        #     font="FontAwesome6Free",
        #     fontsize=12,
        #     foreground=colors["focused_text"],
        #     margin=0,
        #     padding=5,
        #     **light_widgets,
        # ),
        # widget.CPU(
        #     foreground=colors["focused_text"],
        #     format="{load_percent}%",
        #     margin=0,
        #     padding=0,
        #     **widget_defaults,
        #     **light_widgets,
        # ),
        # widget.Sep(
        #     foreground=colors["focused_text"],
        #     padding=10,
        #     size_percent=60,
        #     **light_widgets,
        # ),
        # # CPU temperature
        # widget.TextBox(
        #     text="",
        #     font="FontAwesome6Free",
        #     fontsize=12,
        #     foreground=colors["focused_text"],
        #     padding=5,
        #     **light_widgets,
        # ),
        # widget.ThermalSensor(
        #     foreground=colors["focused_text"], **widget_defaults, **light_widgets
        # ),
        # widget.Sep(linewidth=0, padding=10, **light_widgets),
        # widget.Sep(linewidth=0, padding=10),
        # widget.Sep(linewidth=0, padding=10, **light_widgets),
        # widget.TextBox(
        #     text="",
        #     font="FontAwesome6Free",
        #     fontsize=12,
        #     foreground=colors["focused_text"],
        #     **light_widgets,
        # ),
        widget.Spacer(),
        ########
        ## Middle
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
        widget.Spacer(),
        ########
        ### Right Side
        ##  Tray
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        widget.TextBox(
            text="󰻞",
            mouse_callbacks={
                "Button1": lazy.spawn("google-chrome-stable --app=https://claude.ai/"),
            },
            **mid_widgets,
            **widget_defaults,
        ),
        widget.Sep(linewidth=0, padding=10, **mid_widgets),
        widget.TextBox(
            text="",
            mouse_callbacks={
                "Button1": lazy.spawn("nemo"),
            },
            **widget_defaults,
            **mid_widgets,
        ),
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
        ##  Time
        widget.Sep(
            linewidth=0,
            padding=10,
        ),
        widget.Clock(
            format=" %d %b | %I:%M%P ",
            mouse_callbacks={
                "Button1": lazy.spawn("wlogout"),
            },
            **widget_defaults,
            **mid_widgets,
        ),
        widget.Sep(linewidth=0, padding=7),
    ]

    return widgets_list
