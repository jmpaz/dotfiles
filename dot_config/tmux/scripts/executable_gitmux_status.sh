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

if ! git -C "$pane_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    fallback
    exit 0
fi

if ! output=$(gitmux "$pane_path" 2>/dev/null); then
    fallback
    exit 0
fi

if [ -z "$output" ]; then
    fallback
    exit 0
fi

# Strip the stashed indicator (⚑ N) from gitmux output, keeping other flags intact.
strip_stash() {
    python3 -c '
import sys, re
text = sys.stdin.read()
text = re.sub(r"\s*#\[[^]]*]⚑(?:\s*\d+)?", "", text)
idx = text.find(" - ")
if idx != -1:
    tail_plain = re.sub(r"#\[[^]]*]", "", text[idx + 3:]).strip()
    if tail_plain in ("", "✔"):
        separator = " #[fg=default,bg=default]|#[none]"
        if text[idx:idx + 3] == " - ":
            text = text[:idx] + separator + text[idx + 3:]
        else:
            text = text[:idx] + separator + text[idx + 2:]
text = re.sub(r"\s{2,}", " ", text)
sys.stdout.write(text.strip())
'
}

stripped_output=$(printf '%s' "$output" | strip_stash)
if [ -n "$stripped_output" ]; then
    output=$stripped_output
fi

diff_totals() {
    local diff_args=("$@")
    local added_total=0
    local deleted_total=0

    while IFS=$'\t' read -r added deleted _; do
        if [[ $added =~ ^[0-9]+$ ]]; then
            added_total=$((added_total + added))
        fi
        if [[ $deleted =~ ^[0-9]+$ ]]; then
            deleted_total=$((deleted_total + deleted))
        fi
    done < <(git -C "$pane_path" diff --no-ext-diff --numstat "${diff_args[@]}" 2>/dev/null)

    printf '%s %s\n' "$added_total" "$deleted_total"
}

format_segment() {
    local net=$1
    local symbol=$2

    local color
    if (( net > 0 )); then
        color="#[fg=green]"
    elif (( net < 0 )); then
        color="#[fg=red]"
    else
        color="#[fg=yellow]"
    fi

    printf '%s%s %d' "$color" "$symbol" "${net#-}"
}

read -r unstaged_insertions unstaged_deletions < <(diff_totals)
read -r staged_insertions staged_deletions < <(diff_totals --cached)

unstaged_total=$((unstaged_insertions + unstaged_deletions))
staged_total=$((staged_insertions + staged_deletions))

segments=()

if (( staged_total > 0 )); then
    staged_net=$((staged_insertions - staged_deletions))
    segments+=("$(format_segment "$staged_net" "󰔶")")
fi

if (( unstaged_total > 0 )); then
    unstaged_net=$((unstaged_insertions - unstaged_deletions))
    segments+=("$(format_segment "$unstaged_net" "󰇂")")
fi

if (( ${#segments[@]} > 0 )); then
    printf '%s | %s#[fg=default,bg=default]' \
        "$output" "$(IFS=' '; printf '%s' "${segments[*]}")"
else
    printf '%s' "$output"
fi
