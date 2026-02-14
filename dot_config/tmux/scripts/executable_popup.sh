#!/bin/bash

if [ -n "$TMUX" ]; then
    socket_path=$(tmux display-message -p '#{socket_path}')
    current_session=$(tmux display-message -p '#{session_name}')

    if [[ "$socket_path" == */popup ]] || [[ "$current_session" =~ ^popup_ ]]; then
        tmux detach-client || {
            tmux display-message "popup: failed to detach nested client"
            exit 1
        }
        exit 0
    fi

    current_window=$(tmux display-message -p '#{window_id}')
    popup_session="popup_${current_window#@}"
    popup_path=$(tmux display-message -p -F '#{pane_current_path}')
    tmux popup -d "$popup_path" -xC -yC -w80% -h80% -E \
        env TMUX= tmux -L popup -f "$HOME/.config/tmux/tmux.conf" new-session -A -s "$popup_session" -c "$popup_path" || {
        tmux display-message "popup: failed to open nested session $popup_session"
        exit 1
    }
else
    echo "Not in a tmux session" >&2
    exit 1
fi

exit 0
