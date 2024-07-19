import subprocess
import os
from libqtile import hook, qtile
from .platform import is_wayland
from .theme import initialize_wallpapers


@hook.subscribe.startup_once
def autostart():
    if not is_wayland():
        scripts_path = "/home/josh/bin/startup"
        scripts = ["screens.sh", "rclone_mount.sh"]
        commands = [
            "/home/josh/.nix-profile/bin/redshift",
            "darkman run",
            "picom",
        ]
        commands += [os.path.join(scripts_path, script) for script in scripts]
        for command in commands:
            subprocess.Popen(command, shell=True)
    else:
        commands = [
            "kanshi",
        ]
        for command in commands:
            subprocess.Popen(command, shell=True)
        pass

    initialize_wallpapers(qtile)
