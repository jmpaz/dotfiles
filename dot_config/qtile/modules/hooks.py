import subprocess
import os
from libqtile import hook


@hook.subscribe.startup_once
def autostart():
    scripts_path = "/home/josh/bin/startup"
    scripts = ["screens.sh", "rclone_mount.sh"]
    commands = [
        "/home/josh/.nix-profile/bin/redshift",
        "nitrogen --restore",
        "darkman run",
        "picom",
    ]
    commands += [os.path.join(scripts_path, script) for script in scripts]
    for command in commands:
        subprocess.Popen(command, shell=True)
