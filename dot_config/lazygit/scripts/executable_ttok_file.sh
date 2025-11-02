#!/usr/bin/env bash

set -eo pipefail

ttok_bin=${TTOK_BIN:-$(command -v ttok-rs 2>/dev/null || command -v ttok 2>/dev/null || true)}
if [[ -z "$ttok_bin" ]]; then
    echo "ttok-rs not found on PATH" >&2
    exit 1
fi

file_path_raw=${1:-}
has_staged_raw=${2:-}
has_unstaged_raw=${3:-}
selected_path_raw=${4:-}

normalize_value() {
    local value=$1
    if [[ "$value" == "<no value>" ]]; then
        echo ""
    else
        echo "$value"
    fi
}

file_path=$(normalize_value "$file_path_raw")
selected_path=$(normalize_value "$selected_path_raw")

if [[ -z "$file_path" && -n "$selected_path" ]]; then
    file_path=$selected_path
fi

if [[ -z "$file_path" ]]; then
    cat <<'EOF'
No path received from Lazygit.
Hint: Lazygit's custom command templates currently can't expose every item in a multi-file range selection, so this command only works when a single file or directory is focused. See docs/Custom_Command_Keybindings.md for details.
EOF
    exit 0
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "$repo_root" ]]; then
    echo "Not inside a git repository" >&2
    exit 1
fi

cd "$repo_root"

# Rebase any absolute path back to a repo-relative path for Git commands.
if [[ "$file_path" = /* ]]; then
    relative_candidate=${file_path#"$repo_root"/}
    if [[ "$relative_candidate" != "$file_path" ]]; then
        file_path=$relative_candidate
    fi
fi

if [[ "$file_path" = /* ]]; then
    abs_path="$file_path"
else
    abs_path="$repo_root/$file_path"
fi

path_is_dir=0
if [[ -d "$abs_path" ]]; then
    path_is_dir=1
fi

interpret_flag() {
    local value=${1:-auto}
    value=${value,,}
    case "$value" in
        ""|auto) echo "auto" ;;
        1|true|yes|on) echo 1 ;;
        0|false|no|off) echo 0 ;;
        *) echo "auto" ;;
    esac
}

sanitize_number() {
    local value=${1:-0}
    if [[ $value =~ ^-?[0-9]+$ ]]; then
        printf '%s' "$value"
    else
        printf '0'
    fi
}

staged_added=0
staged_removed=0
staged_net=0
staged_section_printed=0
unstaged_added=0
unstaged_removed=0
unstaged_net=0
unstaged_section_printed=0
untracked_added=0
untracked_removed=0
untracked_net=0
untracked_section_printed=0

print_token_totals() {
    local heading=$1
    local output=$2
    local store_prefix=${3:-}
    local added removed net

    if [[ -z "$output" ]]; then
        added=0
        removed=0
    else
        read -r added removed <<<"$output"
    fi

    added=$(sanitize_number "$added")
    removed=$(sanitize_number "$removed")
    net=$((added - removed))

    printf '%s\n' "$heading"
    printf '  tokens added: %d\n' "$added"
    printf '  tokens removed: %d\n' "$removed"
    printf '  net change: %+d tokens\n\n' "$net"

    if [[ -n "$store_prefix" ]]; then
        printf -v "${store_prefix}_added" '%d' "$added"
        printf -v "${store_prefix}_removed" '%d' "$removed"
        printf -v "${store_prefix}_net" '%d' "$net"
        printf -v "${store_prefix}_section_printed" '%d' 1
    fi
}

git_pathspec_args=("--" "$file_path")
ttok_pathspec=("$file_path")
if (( path_is_dir )); then
    git_pathspec_args+=(":(glob)$file_path/**")
    ttok_pathspec+=(":(glob)$file_path/**")
fi

detect_git_changes() {
    local diff_mode=$1
    shift
    local args=("$@")
    local cmd=(git diff)
    if [[ -n "$diff_mode" ]]; then
        cmd+=("$diff_mode")
    fi
    cmd+=(--quiet "${args[@]}")
    if "${cmd[@]}" 2>/dev/null; then
        echo 0
    else
        local exit_code=$?
        if (( exit_code == 1 )); then
            echo 1
        else
            echo 0
        fi
    fi
}

mapfile -d '' -t untracked_rel < <(git ls-files -z --others --exclude-standard "${git_pathspec_args[@]}" 2>/dev/null || true)
declare -a untracked_abs=()
for rel_path in "${untracked_rel[@]}"; do
    if [[ -z "$rel_path" ]]; then
        continue
    fi
    if [[ "$rel_path" = /* ]]; then
        untracked_abs+=("$rel_path")
    else
        untracked_abs+=("$repo_root/$rel_path")
    fi
done
has_untracked=0
if (( ${#untracked_abs[@]} > 0 )); then
    has_untracked=1
fi

staged_flag=$(interpret_flag "$has_staged_raw")
tracked_staged_changes=$(detect_git_changes "--cached" "${git_pathspec_args[@]}")
if [[ "$staged_flag" == "auto" ]]; then
    has_staged=$tracked_staged_changes
else
    has_staged=$staged_flag
fi

unstaged_flag=$(interpret_flag "$has_unstaged_raw")
tracked_unstaged_changes=$(detect_git_changes "" "${git_pathspec_args[@]}")
if [[ "$unstaged_flag" == "auto" ]]; then
    has_unstaged=$(( tracked_unstaged_changes || has_untracked ))
else
    has_unstaged=$unstaged_flag
fi

run_ttok_git() {
    local heading=$1
    local store_prefix=$2
    shift 2
    local extra_args=("$@")
    local output
    if [[ ${#extra_args[@]} -gt 0 ]]; then
        output=$("$ttok_bin" --git "${extra_args[@]}" -- "${ttok_pathspec[@]}" 2>/dev/null || true)
    else
        output=$("$ttok_bin" --git -- "${ttok_pathspec[@]}" 2>/dev/null || true)
    fi
    print_token_totals "$heading" "$output" "$store_prefix"
}

run_ttok_untracked() {
    local heading=$1
    local store_prefix=$2
    shift 2
    local files=("$@")
    (( ${#files[@]} > 0 )) || return 1

    local diff_output
    diff_output=$(
        {
            for path in "${files[@]}"; do
                git diff --no-index -- /dev/null "$path" || true
            done
        } 2>/dev/null
    )
    if [[ -z "$diff_output" ]]; then
        return 1
    fi

    local output
    output=$(printf '%s' "$diff_output" | "$ttok_bin" --diff 2>/dev/null || true)
    if [[ -z "$output" ]]; then
        return 1
    fi

    print_token_totals "$heading" "$output" "$store_prefix"
}

run_ttok_commit() {
    local commit=$1
    local diff_output
    diff_output=$(git diff-tree --no-commit-id --root -p "$commit" -- "${ttok_pathspec[@]}" 2>/dev/null || true)
    if [[ -z "$diff_output" ]]; then
        return 1
    fi
    local output
    output=$(printf '%s' "$diff_output" | "$ttok_bin" --diff 2>/dev/null || true)
    if [[ -z "$output" ]]; then
        return 1
    fi

    local added removed net short_commit message
    read -r added removed <<<"$output"
    added=$(sanitize_number "$added")
    removed=$(sanitize_number "$removed")
    net=$((added - removed))

    short_commit=${commit:0:7}
    message=$(git log --pretty=format:%s -n1 "$commit" 2>/dev/null | head -n1)

    printf 'Last commit %s\n' "$short_commit"
    if [[ -n "$message" ]]; then
        printf '  %s\n' "$message"
    fi
    printf '  tokens added: %d\n' "$added"
    printf '  tokens removed: %d\n' "$removed"
    printf '  net change: %+d tokens\n\n' "$net"
}

printf 'Path: %s\n\n' "$file_path"

sections_printed=0

if (( has_staged )); then
    run_ttok_git "Staged changes" staged --cached
    sections_printed=1
fi

if (( tracked_unstaged_changes )); then
    run_ttok_git "Unstaged changes" unstaged
    sections_printed=1
fi

if (( has_untracked )); then
    if run_ttok_untracked "Untracked changes" untracked "${untracked_abs[@]}"; then
        sections_printed=1
    fi
fi

if (( staged_section_printed == 1 && unstaged_section_printed == 1 )); then
    combined_net=$((staged_net + unstaged_net))
    printf 'net staged %+d, unstaged %+d, combined %+d tokens\n' "$staged_net" "$unstaged_net" "$combined_net"
fi

if (( sections_printed == 0 )); then
    last_commit=$(git rev-list -1 HEAD -- "${ttok_pathspec[@]}" 2>/dev/null || true)
    if [[ -n "$last_commit" ]]; then
        if run_ttok_commit "$last_commit"; then
            sections_printed=1
        fi
    fi
fi

if (( sections_printed == 0 )); then
    echo "No diff data available for this path."
fi
