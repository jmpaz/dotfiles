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

    if [[ "$(uname -s)" == "Darwin" ]]; then
        popup_cmd=$(printf '%q ' \
            env TMUX= tmux -L popup -f "$HOME/.config/tmux/tmux.conf" \
            new-session -A -s "$popup_session" -c "$popup_path")
        tmux popup -d "$popup_path" -xC -yC -w80% -h80% -E "${popup_cmd% }" || {
            tmux display-message "popup: failed to open nested session $popup_session"
            exit 1
        }
    else
        if ! tmux has-session -t "$popup_session" 2>/dev/null; then
            tmux new-session -ds "$popup_session" -c "$popup_path" || {
                tmux display-message "popup: failed to create session $popup_session"
                exit 1
            }
        fi
        tmux popup -d "$popup_path" -xC -yC -w80% -h80% -E "tmux attach-session -t \"$popup_session\"" || {
            tmux display-message "popup: failed to attach session $popup_session"
            exit 1
        }
    fi
else
    echo "Not in a tmux session" >&2
    exit 1
fi

exit 0
