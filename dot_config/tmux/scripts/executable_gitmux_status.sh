#!/usr/bin/env bash

pane_path=$1

fallback() {
    printf '%s' '#S'
}

if ! command -v gitmux >/dev/null 2>&1; then
    fallback
    exit 0
fi

if [ -z "$pane_path" ] || [ ! -d "$pane_path" ]; then
    pane_path="."
fi

if ! output=$(gitmux "$pane_path" 2>/dev/null); then
    fallback
    exit 0
fi

if [ -n "$output" ]; then
    printf '%s' "$output"
else
    fallback
fi
