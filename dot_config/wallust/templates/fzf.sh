#!/bin/sh

export FZF_DEFAULT_OPTS="--color=\
bg+:#{{background | blend(color0) | blend(color0) | replace('#','') | strip}},\
bg:#{{background | replace('#','')}},\
border:#{{color8 | replace('#','')}},\
spinner:#{{color6 | replace('#','')}},\
hl:#{{color3 | replace('#','')}},\
fg:#{{foreground | replace('#','')}},\
header:#{{color3 | replace('#','')}},\
info:#{{color11 | replace('#','')}},\
pointer:#{{color1 | replace('#','')}},\
marker:#{{color1 | replace('#','')}},\
fg+:#{{foreground | replace('#','')}},\
preview-bg:#{{background | blend(color0) | blend(color0) | replace('#','') | strip}},\
prompt:#{{color4 | replace('#','')}},\
hl+:#{{color4 | replace('#','')}}"

