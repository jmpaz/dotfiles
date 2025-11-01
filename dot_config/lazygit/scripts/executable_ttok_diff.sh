#!/usr/bin/env bash

set -eo pipefail

ttok_bin=${TTOK_BIN:-$(command -v ttok-rs 2>/dev/null || command -v ttok 2>/dev/null || true)}
if [[ -z "$ttok_bin" ]]; then
    echo "ttok-rs not found on PATH" >&2
    exit 1
fi

from=$1
to=$2
commit=$3

short_hash() {
    local hash=$1
    if [[ -z "$hash" ]]; then
        printf '--'
    else
        printf '%s' "${hash:0:7}"
    fi
}

describe_commit() {
    local hash=$1
    git log --pretty=format:%s -n1 "$hash" 2>/dev/null | head -n1
}

spec=""
description=""

if [[ -n "$from" && -n "$to" ]]; then
    if [[ "$from" != "$to" ]]; then
        spec="${from}..${to}"
        description="Range $(short_hash "$from")..$(short_hash "$to")"
    else
        commit=$from
    fi
fi

if [[ -z "$spec" ]]; then
    if [[ -n "$commit" ]]; then
        parent=$(git rev-parse "${commit}^" 2>/dev/null || echo "")
        if [[ -n "$parent" ]]; then
            spec="${parent}..${commit}"
            description="Commit $(short_hash "$commit") vs $(short_hash "$parent")"
        else
            spec="${commit}^!"
            description="Commit $(short_hash "$commit") (initial commit)"
        fi
        message=$(describe_commit "$commit")
        if [[ -n "$message" ]]; then
            description+=$' — '
            description+="$message"
        fi
    else
        description="Working tree"
    fi
fi

if [[ -z "$spec" ]]; then
    spec=""
fi

if [[ -n "$spec" ]]; then
    output=$("$ttok_bin" --git "$spec")
else
    output=$("$ttok_bin" --git)
fi

read -r added removed <<<"$output"
added=${added:-0}
removed=${removed:-0}
if ! [[ $added =~ ^[0-9]+$ ]]; then added=0; fi
if ! [[ $removed =~ ^[0-9]+$ ]]; then removed=0; fi
net=$((added - removed))

printf '%s\n' "$description"
printf '  tokens added: %d\n' "$added"
printf '  tokens removed: %d\n' "$removed"
printf '\n'
printf '  net change: %+d tokens\n' "$net"
