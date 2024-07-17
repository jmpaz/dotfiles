import subprocess


def is_wayland():
    return "WAYLAND_DISPLAY" in subprocess.check_output(
        ["env"], universal_newlines=True
    )


def get_number_of_screens():
    if is_wayland():
        # output = subprocess.check_output(["wlr-randr"], universal_newlines=True)
        # return len([line for line in output.split("\n") if "connected" in line])
        return 1
    else:
        output = subprocess.check_output(
            ["xrandr", "--listmonitors"], universal_newlines=True
        )
        return int(output.split("\n")[0].split(":")[1].strip())
