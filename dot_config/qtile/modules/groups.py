from libqtile.config import DropDown, Group, ScratchPad

groups = []

# Define group names and layouts
group_names = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
]
group_layouts = ["bonsai"] * 10

# Create label for groups and assign them layout
for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
        )
    )


scratchpad = ScratchPad(
    "scratchpad",
    [
        DropDown(
            "term",
            "kitty",
            width=0.997,
            height=0.6,
            x=0,
            y=0,
            opacity=0.95,
        ),
        DropDown(
            "volume", "pavucontrol", width=0.8, height=0.8, x=0.1, y=0.1, opacity=0.95
        ),
        DropDown(
            "files",
            "nemo",
            width=0.8,
            height=0.8,
            x=0.1,
            y=0.1,
            opacity=0.95,
        ),
        DropDown("bitwarden", "bitwarden", width=0.4, height=0.6, x=0.3, y=0.1),
    ],
)