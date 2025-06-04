function sudo-nvim
    set -l nvim_path (which nvim)
    if test -z "$nvim_path"
        echo "Error: nvim not found in your PATH." >&2
        return 1
    end

    if test (count $argv) -eq 0
        env SUDO_EDITOR=$nvim_path sudoedit
    else
        # forward arguments
        env SUDO_EDITOR=$nvim_path sudoedit $argv
    end
end

