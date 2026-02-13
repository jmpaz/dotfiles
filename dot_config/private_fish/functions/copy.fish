function copy
    set -l in_ssh 0
    if set -q SSH_TTY; or set -q SSH_CONNECTION; or set -q SSH_CLIENT
        set in_ssh 1
    end

    set -l use_osc52 1
    if contains -- -i $argv; or contains -- -t $argv; or contains -- --type $argv
        set use_osc52 0
    else
        for arg in $argv
            if string match -rq '^--type=' -- $arg
                set use_osc52 0
                break
            end
        end
    end

    set -l backend
    if command -q pbcopy
        set backend pbcopy
    else if test $in_ssh -eq 1
        if command -q xclip
            set backend xclip -selection clipboard
        else if command -q tmux
            set backend tmux load-buffer -
        end
    else if command -q wl-copy
        set backend wl-copy
    else if command -q xclip
        set backend xclip -selection clipboard
    else if command -q tmux
        set backend tmux load-buffer -
    end

    set -l shcopy_args
    if set -q TMUX
        set shcopy_args --term tmux
    end

    set -l try_osc52 0
    if test $in_ssh -eq 1; and command -q shcopy
        if test $use_osc52 -eq 1
            set try_osc52 1
        end
    end

    if test -z "$backend"; and test $in_ssh -eq 0
        return 1
    end

    if not test -t 0
        set -l tmp (mktemp)
        cat > $tmp

        if test $try_osc52 -eq 1
            command shcopy $shcopy_args $argv < $tmp
            if test $status -eq 0
                rm -f $tmp
                return 0
            end
        end

        if test -n "$backend"
            command $backend $argv < $tmp
            set -l status_code $status
            rm -f $tmp
            return $status_code
        end

        rm -f $tmp
        return 1
    end

    if test $try_osc52 -eq 1
        command shcopy $shcopy_args $argv
        if test $status -eq 0
            return 0
        end
    end

    if test -n "$backend"
        command $backend $argv
        return $status
    end

    return 1
end
