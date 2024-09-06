#!/bin/bash

if [ -n "$TMUX" ]; then
    current_window=$(tmux display-message -p '#{window_id}')
    popup_session="popup_${current_window}"
    current_session=$(tmux display-message -p '#{session_name}')

    if [[ "$current_session" == popup_* ]]; then
        # in a popup session, so detach
        tmux detach-client || exit 1
    else
        # not in a popup, so create one for this window
        tmux popup -d '#{pane_current_path}' -xC -yC -w80% -h80% -E "tmux attach -t $popup_session || tmux new-session -s $popup_session" || exit 1
    fi
else
    echo "Not in a tmux session" >&2
    exit 1
fi

exit 0
