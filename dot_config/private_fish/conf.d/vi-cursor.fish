# vi-cursor.fish - Vi mode cursor shape handling

if status is-interactive

    function __fish_apply_vi_cursor -a mode
        switch $mode
            case default
                printf '\e[2 q'
            case insert
                printf '\e[6 q'
            case replace_one
                printf '\e[4 q'
            case visual
                printf '\e[2 q'
        end
    end

    function __fish_vi_cursor_listener --on-variable fish_bind_mode
        __fish_apply_vi_cursor $fish_bind_mode
    end

    function __fish_vi_cursor_prompt --on-event fish_prompt
        if set -q fish_bind_mode
            __fish_apply_vi_cursor $fish_bind_mode
        else
            __fish_apply_vi_cursor insert
        end
    end

    if set -q fish_bind_mode
        __fish_apply_vi_cursor $fish_bind_mode
    else
        __fish_apply_vi_cursor insert
    end

end
