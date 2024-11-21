#!/bin/bash

if [ -n "$TMUX" ]; then
    current_window=$(tmux display-message -p '#{window_id}')
    popup_session="popup_${current_window}"
    current_session=$(tmux display-message -p '#{session_name}')

    if [[ "$current_session" =~ ^popup_ ]]; then
        tmux detach-client || exit 1
    else
        if ! tmux has-session -t "$popup_session" 2>/dev/null; then
            tmux new-session -d -s "$popup_session" -c '#{pane_current_path}' || exit 1
        fi
        tmux popup -d '#{pane_current_path}' -xC -yC -w80% -h80% -E "tmux attach-session -t $popup_session" || exit 1
    fi
else
    echo "Not in a tmux session" >&2
    exit 1
fi

exit 0
