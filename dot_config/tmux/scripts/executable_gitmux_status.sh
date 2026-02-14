#!/usr/bin/env bash

pane_path=$1
session_activity=$2

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

cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/tmux/gitmux-status"
cache_key=$(printf '%s' "$pane_path" | sed 's/[^A-Za-z0-9._-]/_/g')
cache_file="$cache_root/$cache_key"

read_cached_output() {
    [ -f "$cache_file" ] || return 1
    cat "$cache_file"
}

write_cached_output() {
    local value=$1
    local tmp_file
    mkdir -p "$cache_root" 2>/dev/null || return 0
    tmp_file=$(mktemp "$cache_root/tmp.XXXXXX" 2>/dev/null) || return 0
    printf '%s' "$value" > "$tmp_file"
    mv "$tmp_file" "$cache_file" 2>/dev/null || true
}

session_is_idle() {
    local idle_after

    idle_after=${GITMUX_IDLE_AFTER:-}
    if [ -z "$idle_after" ] && command -v tmux >/dev/null 2>&1; then
        idle_after=$(tmux show-option -gqv @gitmux_idle_after 2>/dev/null || true)
    fi
    if ! [[ $idle_after =~ ^[0-9]+$ ]]; then
        idle_after=120
    fi
    if (( idle_after <= 0 )); then
        return 1
    fi
    if ! [[ ${session_activity:-} =~ ^[0-9]+$ ]]; then
        return 1
    fi

    local now_epoch
    now_epoch=$(date +%s 2>/dev/null || printf '%s' 0)
    if ! [[ $now_epoch =~ ^[0-9]+$ ]]; then
        return 1
    fi

    (( now_epoch - session_activity >= idle_after ))
}

if session_is_idle; then
    if cached_output=$(read_cached_output); then
        printf '%s' "$cached_output"
        exit 0
    fi
fi

TTOK_CMD=""
if TTOK_CMD=$(command -v ttok-rs 2>/dev/null); then
    TTOK_CMD=${TTOK_CMD:-}
elif TTOK_CMD=$(command -v ttok 2>/dev/null); then
    TTOK_CMD=${TTOK_CMD:-}
else
    TTOK_CMD=""
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

run_ttok_git() {
    if [ -z "$TTOK_CMD" ]; then
        return 1
    fi
    (
        cd -- "${pane_path:-.}" 2>/dev/null || exit 1
        "$TTOK_CMD" --git "$@" 2>/dev/null
    )
}

hash_string() {
    local input=$1
    if command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$input" | sha256sum 2>/dev/null | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        printf '%s' "$input" | shasum -a 256 2>/dev/null | awk '{print $1}'
    elif command -v md5sum >/dev/null 2>&1; then
        printf '%s' "$input" | md5sum 2>/dev/null | awk '{print $1}'
    else
        printf '%s' "$input" | sed 's/[^A-Za-z0-9]/_/g'
    fi
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

TOKEN_TOTALS_READY=0
TOKEN_STAGED_ADD=0
TOKEN_STAGED_DEL=0
TOKEN_UNSTAGED_ADD=0
TOKEN_UNSTAGED_DEL=0

compute_token_totals() {
    if [ "$TOKEN_TOTALS_READY" = "1" ]; then
        return
    fi

    TOKEN_TOTALS_READY=1
    TOKEN_STAGED_ADD=0
    TOKEN_STAGED_DEL=0
    TOKEN_UNSTAGED_ADD=0
    TOKEN_UNSTAGED_DEL=0

    if [ -z "$TTOK_CMD" ]; then
        return
    fi

    local git_dir work_tree worktree_hash
    git_dir=$(git -C "$pane_path" rev-parse --absolute-git-dir 2>/dev/null)
    work_tree=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$pane_path")
    if [ -z "$work_tree" ]; then
        work_tree=$pane_path
    fi
    worktree_hash=$(hash_string "$work_tree")
    if [ -z "$worktree_hash" ]; then
        worktree_hash="worktree"
    fi
    local cache_root cache_file
    if [ -n "$git_dir" ]; then
        cache_root="$git_dir/gitmux-cache"
    else
        cache_root="$pane_path/.gitmux-cache"
    fi
    mkdir -p "$cache_root" 2>/dev/null || true
    cache_file="$cache_root/token-totals"

    local status_snapshot status_hash
    status_snapshot=$(git -C "$pane_path" status --porcelain 2>/dev/null || true)
    status_hash=$(hash_string "$status_snapshot")
    if [ -z "$status_hash" ]; then
        status_hash="clean"
    fi

    if [ -n "$status_hash" ] && [ -f "$cache_file" ]; then
        local cached_hash cached_worktree cached_staged_add cached_staged_del cached_unstaged_add cached_unstaged_del
        read -r cached_hash cached_worktree cached_staged_add cached_staged_del cached_unstaged_add cached_unstaged_del < "$cache_file"
        if [ "$cached_hash" = "$status_hash" ] && [ "$cached_worktree" = "$worktree_hash" ]; then
            TOKEN_STAGED_ADD=${cached_staged_add:-0}
            TOKEN_STAGED_DEL=${cached_staged_del:-0}
            TOKEN_UNSTAGED_ADD=${cached_unstaged_add:-0}
            TOKEN_UNSTAGED_DEL=${cached_unstaged_del:-0}
            return
        fi
    fi

    if [ "${TTOK_CMD##*/}" = "ttok-rs" ]; then
        local unstaged_output staged_output
        unstaged_output=$(run_ttok_git)
        staged_output=$(run_ttok_git --cached)
        read -r TOKEN_UNSTAGED_ADD TOKEN_UNSTAGED_DEL <<<"${unstaged_output:-0 0}"
        read -r TOKEN_STAGED_ADD TOKEN_STAGED_DEL <<<"${staged_output:-0 0}"
    else
        TOKEN_UNSTAGED_ADD=$(git -C "$pane_path" diff --no-ext-diff --unified=0 2>/dev/null \
            | awk 'substr($0,1,1)=="+" && substr($0,1,3)!="+++" {print substr($0,2)}' \
            | "$TTOK_CMD" 2>/dev/null)
        TOKEN_UNSTAGED_DEL=$(git -C "$pane_path" diff --no-ext-diff --unified=0 2>/dev/null \
            | awk 'substr($0,1,1)=="-" && substr($0,1,3)!="---" {print substr($0,2)}' \
            | "$TTOK_CMD" 2>/dev/null)
        TOKEN_STAGED_ADD=$(git -C "$pane_path" diff --no-ext-diff --unified=0 --cached 2>/dev/null \
            | awk 'substr($0,1,1)=="+" && substr($0,1,3)!="+++" {print substr($0,2)}' \
            | "$TTOK_CMD" 2>/dev/null)
        TOKEN_STAGED_DEL=$(git -C "$pane_path" diff --no-ext-diff --unified=0 --cached 2>/dev/null \
            | awk 'substr($0,1,1)=="-" && substr($0,1,3)!="---" {print substr($0,2)}' \
            | "$TTOK_CMD" 2>/dev/null)
    fi

    for var in TOKEN_STAGED_ADD TOKEN_STAGED_DEL TOKEN_UNSTAGED_ADD TOKEN_UNSTAGED_DEL; do
        local value
        value=${!var}
        if ! [[ $value =~ ^[0-9]+$ ]]; then
            printf -v "$var" '%s' 0
        fi
    done

    if [ -n "$status_hash" ] && [ -n "$cache_file" ]; then
        local tmp_file
        tmp_file=$(mktemp "$cache_root/tmp.XXXXXX" 2>/dev/null) || return
        printf '%s %s %s %s %s %s\n' "$status_hash" "$worktree_hash" "$TOKEN_STAGED_ADD" "$TOKEN_STAGED_DEL" "$TOKEN_UNSTAGED_ADD" "$TOKEN_UNSTAGED_DEL" > "$tmp_file"
        mv "$tmp_file" "$cache_file" 2>/dev/null || true
    fi
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

VALUE_SUFFIX=""
VALUE_PREFIX=""
SEPARATOR=" | "

requested_tokens=""
if command -v tmux >/dev/null 2>&1; then
    requested_tokens=$(tmux show-option -gqv @gitmux_tokens 2>/dev/null || true)
fi

use_tokens_default=0
if [ "${TTOK_CMD##*/}" = "ttok-rs" ]; then
    use_tokens_default=1
fi

use_tokens=$use_tokens_default
if [ -n "$requested_tokens" ]; then
    lower_value=$(printf '%s' "$requested_tokens" | tr '[:upper:]' '[:lower:]')
    if [ "$lower_value" = "1" ] || [ "$lower_value" = "on" ] || [ "$lower_value" = "true" ]; then
        if [ -n "$TTOK_CMD" ]; then
            use_tokens=1
        else
            use_tokens=0
        fi
    elif [ "$lower_value" = "0" ] || [ "$lower_value" = "off" ] || [ "$lower_value" = "false" ]; then
        use_tokens=0
    fi
fi

if (( use_tokens == 1 )); then
    VALUE_PREFIX="·"
    compute_token_totals
    unstaged_insertions=$TOKEN_UNSTAGED_ADD
    unstaged_deletions=$TOKEN_UNSTAGED_DEL
    staged_insertions=$TOKEN_STAGED_ADD
    staged_deletions=$TOKEN_STAGED_DEL
else
    read -r unstaged_insertions unstaged_deletions < <(diff_totals)
    read -r staged_insertions staged_deletions < <(diff_totals --cached)
fi

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

final_output=$output
if (( ${#segments[@]} > 0 )); then
    final_output=$(printf '%s%s%s#[fg=default,bg=default]' \
        "$output" "$SEPARATOR" "$(IFS=' '; printf '%s' "${segments[*]}")")
fi

write_cached_output "$final_output"
printf '%s' "$final_output"
