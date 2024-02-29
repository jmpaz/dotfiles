import tomllib
from pathlib import Path


def format_value(value):
    if isinstance(value, str):
        return f'"{value}"'
    elif isinstance(value, bool):
        return str(value).lower()
    else:
        return str(value)


def serialize_toml(data):
    toml_content = ""
    age_related = 'encryption = "age"'
    for section, values in data.items():
        if section != "age":
            toml_content += f"[{section}]\n"
            for key, value in values.items():
                # Ensure `encryption` key is handled separately
                if f"{key} = {format_value(value)}" != age_related:
                    toml_content += f"    {key} = {format_value(value)}\n"
            toml_content += "\n"
    # Add `encryption = "age"` line directly above the `[age]` section, without indentation
    if "age" in data:
        toml_content += f"{age_related}\n[age]\n"
        for key, value in data["age"].items():
            toml_content += f"    {key} = {format_value(value)}\n"
    return toml_content


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
                if section in base_data:
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
