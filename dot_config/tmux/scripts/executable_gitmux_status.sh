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

token_diff_totals() {
    local diff_args=("$@")
    local added_tokens removed_tokens

    # Added tokens: lines starting with '+' but not '+++'
    added_tokens=$(git -C "$pane_path" diff --no-ext-diff --unified=0 "${diff_args[@]}" 2>/dev/null \
        | awk 'substr($0,1,1)=="+" && substr($0,1,3)!="+++" {print substr($0,2)}' \
        | ttok 2>/dev/null)
    # Removed tokens: lines starting with '-' but not '---'
    removed_tokens=$(git -C "$pane_path" diff --no-ext-diff --unified=0 "${diff_args[@]}" 2>/dev/null \
        | awk 'substr($0,1,1)=="-" && substr($0,1,3)!="---" {print substr($0,2)}' \
        | ttok 2>/dev/null)

    [[ $added_tokens =~ ^[0-9]+$ ]] || added_tokens=0
    [[ $removed_tokens =~ ^[0-9]+$ ]] || removed_tokens=0

    printf '%s %s\n' "$added_tokens" "$removed_tokens"
}

format_segment() {
    local net=$1
    local symbol=$2
    local suffix=${VALUE_SUFFIX:-}
    local prefix=${VALUE_PREFIX:-}

    local color
    if (( net > 0 )); then
        color="#[fg=green]"
    elif (( net < 0 )); then
        color="#[fg=red]"
    else
        color="#[fg=yellow]"
    fi

    printf '%s%s %s%d%s' "$color" "$symbol" "$prefix" "${net#-}" "$suffix"
}

diff_func=diff_totals
VALUE_SUFFIX=""
VALUE_PREFIX=""
SEPARATOR=" | "

requested_tokens=""
if command -v tmux >/dev/null 2>&1; then
    requested_tokens=$(tmux show-option -gqv @gitmux_tokens 2>/dev/null || true)
fi

use_tokens=0
case "${requested_tokens,,}" in
    1|on|true)
        if command -v ttok >/dev/null 2>&1; then
            use_tokens=1
        fi
        ;;
    0|off|false)
        use_tokens=0
        ;;
    *)
        use_tokens=0
        ;;
esac

if (( use_tokens == 1 )); then
    diff_func=token_diff_totals
    VALUE_PREFIX="·"
fi

read -r unstaged_insertions unstaged_deletions < <($diff_func)
read -r staged_insertions staged_deletions < <($diff_func --cached)

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
    printf '%s%s%s#[fg=default,bg=default]' \
        "$output" "$SEPARATOR" "$(IFS=' '; printf '%s' "${segments[*]}")"
else
    printf '%s' "$output"
fi
