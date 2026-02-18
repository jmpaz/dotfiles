#!/bin/sh

FZF_BINDINGS="\
ctrl-u:half-page-up,\
ctrl-d:half-page-down,\
ctrl-b:page-up,\
ctrl-f:page-down,\
home:first,\
end:last,\
alt-g:first,\
alt-G:last"

if [ -n "${FZF_DEFAULT_OPTS:-}" ]; then
    FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} "
fi

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}--bind=${FZF_BINDINGS}"
