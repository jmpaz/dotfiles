#!/bin/sh

export FZF_DEFAULT_OPTS="--color=\
bg+:#{{background | blend(color4) | replace('#','') | strip}},\
bg:#{{background | replace('#','')}},\
border:#{{color8 | replace('#','')}},\
spinner:#{{color6 | replace('#','')}},\
hl:#{{color3 | replace('#','')}},\
fg:#{{foreground | replace('#','')}},\
header:#{{color3 | replace('#','')}},\
info:#{{color11 | replace('#','')}},\
pointer:#{{color4 | replace('#','')}},\
marker:#{{color4 | replace('#','')}},\
fg+:#{{foreground | replace('#','')}},\
preview-bg:#{{background | replace('#','')}},\
prompt:#{{color4 | replace('#','')}},\
hl+:#{{color4 | replace('#','')}}"
