#!/usr/bin/env bash

set -euo pipefail

action=${1-}
if [ -z "$action" ]; then
    cat <<'USAGE'
Usage: rename_helper.sh <action> <target> [value]
Actions:
  rename-session <target-session> <new-name>
  rename-window  <target-window> <new-name>
  rename-pane    <target-pane> <new-title>
  reset-session  <target-session>
  reset-window   <target-window>
  reset-pane     <target-pane>
USAGE
    exit 1
fi

case "$action" in
    rename-session)
        target=${2-}
        shift 2 || true
        [ -n "${target-}" ] || { echo "Missing target"; exit 1; }
        new_name="$*"
        tmux rename-session -t "$target" "$new_name"
        ;;
    rename-window)
        target=${2-}
        shift 2 || true
        [ -n "${target-}" ] || { echo "Missing target"; exit 1; }
        new_name="$*"
        tmux rename-window -t "$target" "$new_name"
        ;;
    rename-pane)
        target=${2-}
        shift 2 || true
        [ -n "${target-}" ] || { echo "Missing target"; exit 1; }
        new_title="$*"
        tmux select-pane -t "$target" -T "$new_title"
        ;;
    reset-session)
        target=${2-}
        [ -n "${target-}" ] || { echo "Missing target"; exit 1; }
        default_name=$(tmux display-message -p -t "$target" '#{session_id}')
        default_name=${default_name#\$}
        tmux rename-session -t "$target" "$default_name"
        ;;
    reset-window)
        target=${2-}
        [ -n "${target-}" ] || { echo "Missing target"; exit 1; }
        format=$(tmux show-option -gqv automatic-rename-format || true)
        if [ -z "$format" ]; then
            format='#{pane_current_command}'
        fi
        default_name=$(tmux display-message -p -t "$target" "$format")
        tmux set-window-option -t "$target" automatic-rename on
        tmux rename-window -t "$target" "$default_name"
        ;;
    reset-pane)
        target=${2-}
        [ -n "${target-}" ] || { echo "Missing target"; exit 1; }
        tmux select-pane -t "$target" -T ''
        ;;
    *)
        echo "Unknown action: $action"
        exit 1
        ;;
 esac
