#!/usr/bin/env bash

pane_path=$1

if ! command -v gitmux >/dev/null 2>&1; then
    printf '%s' 'tmux'
    exit 0
fi

if [ -z "$pane_path" ] || [ ! -d "$pane_path" ]; then
    pane_path="."
fi

if git -C "$pane_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%s' '#[bold]#S#[nobold] '
else
    printf '%s' 'tmux '
fi
