from libqtile.config import DropDown, Group, Match, ScratchPad

from .layout import primary_layouts, secondary_layouts, shared_layouts
from .platform import get_number_of_screens

num_screens = get_number_of_screens()
groups = []

# Define group names
primary_group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
secondary_group_names = ["I", "II", "III", "IV", "V"]

# Primary monitor
for i in range(len(primary_group_names)):
    groups.append(
        Group(
            name=primary_group_names[i],
            label=primary_group_names[i],
            layouts=primary_layouts + shared_layouts,
            screen_affinity=0,
        )
    )

# Secondary monitor
if num_screens > 1:
    for i in range(len(secondary_group_names)):
        groups.append(
            Group(
                name=secondary_group_names[i],
                label=secondary_group_names[i],
                layouts=secondary_layouts + shared_layouts,
                screen_affinity=1,
            )
        )


scratchpad = ScratchPad(
    "scratchpad",
    [
        DropDown(
            "drop-term",
            "alacritty --class drop-term",
            match=Match(wm_class="drop-term"),
            width=0.7,
            height=0.6,
            x=0.15,
            y=0,
            opacity=1,
        ),
        DropDown(
            "float-term",
            "alacritty --class float-term",
            match=Match(wm_class="float-term"),
            width=0.6,
            height=0.6,
            x=0.2,
            y=0.2,
            opacity=1,
        ),
        DropDown(
            "obsidian",
            "/home/josh/bin/appimage-launch obsidian",
            match=Match(wm_class="obsidian"),
            width=0.7,
            height=0.8,
            x=0.15,
            y=0.1,
            opacity=1,
            on_focus_lost_hide=False,
        ),
        DropDown(
            "audio",
            "pavucontrol",
            width=0.8,
            height=0.8,
            x=0.1,
            y=0.1,
            opacity=0.95,
        ),
        DropDown(
            "obs",
            "obs",
            width=0.5,
            height=0.7,
            x=0.25,
            y=0.1,
            opacity=1,
            on_focus_lost_hide=False,
        ),
        DropDown(
            "files",
            "nemo",
            width=0.8,
            height=0.8,
            x=0.1,
            y=0.1,
            opacity=0.95,
            on_focus_lost_hide=False,
        ),
    ],
)
