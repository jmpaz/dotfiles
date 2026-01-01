from pathlib import Path

import tomllib


def format_value(value):
    if isinstance(value, str):
        return f'"{value}"'
    elif isinstance(value, bool):
        return str(value).lower()
    else:
        return str(value)


def serialize_toml(data):
    lines = []

    def emit_kv(key, value, indent=""):
        lines.append(f"{indent}{key} = {format_value(value)}")

    for key, value in data.items():
        if isinstance(value, dict):
            continue
        if key == "encryption":
            continue
        emit_kv(key, value)

    for section, values in data.items():
        if not isinstance(values, dict):
            continue
        if section == "age" and "encryption" in data:
            emit_kv("encryption", data["encryption"])
        lines.append(f"[{section}]")
        for key, value in values.items():
            emit_kv(key, value, indent="    ")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def merge_toml(base_file_path, vars_dir_path):
    base_path = Path(base_file_path).expanduser()
    vars_dir = Path(vars_dir_path).expanduser()

    if not base_path.exists() or not vars_dir.exists():
        print("Required files or directories are missing.")
        print(f"Base path: {base_path}")
        print(f"Vars dir path: {vars_dir}")
        return

    # Initialize base data with the content of the base file
    with open(base_path, "rb") as bf:
        base_data = tomllib.load(bf)

    # Loop through and update base_data with each vars file
    for update_file in vars_dir.glob("*.toml"):
        with open(update_file, "rb") as uf:
            update_data = tomllib.load(uf)
            for section, values in update_data.items():
                if (
                    section in base_data
                    and isinstance(base_data[section], dict)
                    and isinstance(values, dict)
                ):
                    base_data[section].update(values)
                else:
                    base_data[section] = values

    # Serialize the base data to TOML format and append it to the first line
    first_line = '# sourceDir = "/home/user/.dotfiles"'
    toml_content = f"{first_line}\n{serialize_toml(base_data)}"

    # Write the serialized TOML content back to the base file
    with open(base_path, "w") as bf:
        bf.write(toml_content)
    print(f"Wrote updated TOML to {base_path}")


if __name__ == "__main__":
    merge_toml("~/.config/chezmoi/chezmoi.toml", "~/.local/share/chezmoi/.toml")
