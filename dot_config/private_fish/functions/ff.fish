function ff --description "Fuzzy find files"
    set -l action edit
    set -l root

    for arg in $argv
        switch $arg
            case --cd
                set action cd
            case --edit
                set action edit
            case -h --help
                echo "Usage: ff [--edit|--cd] [ROOT]"
                return 0
            case '*'
                set root $arg
        end
    end

    if test -z "$root"
        if git rev-parse --show-toplevel >/dev/null 2>&1
            set root (git rev-parse --show-toplevel)
        else
            set root .
        end
    end

    if not test -d "$root"
        echo "ff: not a directory: $root" >&2
        return 1
    end

    if not type -q fzf
        echo "ff: fzf is required" >&2
        return 1
    end

    set -l preview
    if type -q bat
        set preview 'bat --theme=ansi --style=numbers --color=always --paging=never --line-range :300 -- {}'
    else
        set preview 'sed -n "1,200p" {}'
    end
    set -l preview_window 'right,60%,border-left,<140(down,65%,border-top)'
    set -l selected

    if type -q fd
        set selected (fd --type f . "$root" | string replace -r '^\.\/' '' | fzf --scheme=path --prompt 'files> ' --preview $preview --preview-window $preview_window)
    else if type -q rg
        set selected (rg --files "$root" | string replace -r '^\.\/' '' | fzf --scheme=path --prompt 'files> ' --preview $preview --preview-window $preview_window)
    else
        echo "ff: install fd (preferred) or rg" >&2
        return 1
    end

    if test -z "$selected"
        return 0
    end

    if test "$action" = cd
        cd (dirname "$selected")
    else
        if set -q EDITOR
            $EDITOR "$selected"
        else
            nvim "$selected"
        end
    end
end
