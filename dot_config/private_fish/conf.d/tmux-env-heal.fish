# tmux env healing:
# - tmux_heal_env for explicit resync,
# - stale-state cleanup with time-based polling

set -g __tmux_heal_poll_seconds 4

function __tmux_env_read_client_var -a pid var
    if test -z "$pid"
        return 1
    end

    set -l env_file "/proc/$pid/environ"
    if not test -r "$env_file"
        return 1
    end

    tr '\0' '\n' < "$env_file" | sed -n "s/^$var=//p" | head -n 1
end

function __tmux_env_apply_from_global -a var
    set -l line (tmux show-environment -g $var 2>/dev/null)
    if test $status -ne 0
        return
    end

    if string match -q -- "-$var" -- $line
        if set -q $var
            set -e -g $var
        end
        return
    end

    set -l desired (string replace -r "^$var=" "" -- $line)
    set -l current (printenv $var 2>/dev/null)
    if test "$current" != "$desired"
        set -gx $var "$desired"
    end
end

function __tmux_sync_remote_ssh_from_client -a client_pid
    for var in SSH_CONNECTION SSH_TTY SSH_CLIENT
        set -l desired (__tmux_env_read_client_var $client_pid $var)
        if test -n "$desired"
            set -l current (printenv $var 2>/dev/null)
            if test "$current" != "$desired"
                set -gx $var "$desired"
            end
        else if set -q $var
            set -e -g $var
        end
    end
end

function __tmux_clear_stale_ssh
    set -l cleared 0
    for var in SSH_CONNECTION SSH_TTY SSH_CLIENT
        if set -q $var
            set -e -g $var
            set cleared 1
        end
    end
    test $cleared -eq 1
end

function tmux_heal_env --description 'Resync current shell env with tmux clipboard/client state'
    if not set -q TMUX
        echo "tmux_heal_env: not inside tmux" >&2
        return 1
    end

    if not command -q tmux
        echo "tmux_heal_env: tmux not found" >&2
        return 1
    end

    ~/.config/tmux/scripts/clipboard_mode.sh >/dev/null 2>&1

    set -l mode (tmux show-options -gqv @remote_clipboard_mode 2>/dev/null)
    if test -z "$mode"
        set mode off
    end

    if test "$mode" = "on"
        set -l client_pid (tmux display-message -p '#{client_pid}' 2>/dev/null)
        __tmux_sync_remote_ssh_from_client $client_pid
        set -g __tmux_heal_last_client_pid "$client_pid"
    else
        __tmux_clear_stale_ssh >/dev/null
        for var in XDG_RUNTIME_DIR WAYLAND_DISPLAY DISPLAY XAUTHORITY
            __tmux_env_apply_from_global $var
        end
        set -g __tmux_heal_last_client_pid ""
    end

    set -g __tmux_heal_last_mode "$mode"
end

function __tmux_env_heal_auto --on-event fish_prompt
    if not status is-interactive
        return
    end

    if not set -q TMUX
        return
    end

    if not command -q tmux
        return
    end

    set -l now_epoch (date +%s 2>/dev/null)
    if test -z "$now_epoch"
        set now_epoch 0
    end

    set -l should_poll 0

    # Poll immediately when shell already looks remote/stale.
    if set -q SSH_CONNECTION; or set -q SSH_TTY; or set -q SSH_CLIENT
        set should_poll 1
    else if set -q __tmux_heal_last_mode; and test "$__tmux_heal_last_mode" = "on"
        set should_poll 1
    else
        if not set -q __tmux_heal_next_poll_epoch
            set -g __tmux_heal_next_poll_epoch 0
        end
        if test "$now_epoch" -ge "$__tmux_heal_next_poll_epoch"
            set should_poll 1
        end
    end

    if test $should_poll -eq 0
        return
    end

    set -g __tmux_heal_next_poll_epoch (math "$now_epoch + $__tmux_heal_poll_seconds")

    set -l status_line (tmux display-message -p '#{@remote_clipboard_mode}\t#{client_pid}' 2>/dev/null)
    if test $status -ne 0
        return
    end

    set -l parts (string split '\t' -- $status_line)
    set -l mode $parts[1]
    set -l client_pid $parts[2]

    if test -z "$mode"
        set mode off
    end

    if test "$mode" = "on"
        set -l needs_remote_sync 0

        if not set -q __tmux_heal_last_client_pid
            set needs_remote_sync 1
        else if test "$client_pid" != "$__tmux_heal_last_client_pid"
            set needs_remote_sync 1
        else if not set -q SSH_CONNECTION; and not set -q SSH_TTY; and not set -q SSH_CLIENT
            set needs_remote_sync 1
        end

        if test $needs_remote_sync -eq 1
            __tmux_sync_remote_ssh_from_client $client_pid
            set -g __tmux_heal_last_client_pid "$client_pid"
        end
    else
        set -l had_stale_ssh 0
        if __tmux_clear_stale_ssh
            set had_stale_ssh 1
        end

        if not set -q __tmux_heal_last_mode; or test "$__tmux_heal_last_mode" = "on"; or test $had_stale_ssh -eq 1
            for var in XDG_RUNTIME_DIR WAYLAND_DISPLAY DISPLAY XAUTHORITY
                __tmux_env_apply_from_global $var
            end
        end

        set -g __tmux_heal_last_client_pid ""
    end

    set -g __tmux_heal_last_mode "$mode"
end
