#!/bin/sh

BACKGROUND=0x{{color2 | blend(color0) | blend(color0) | strip}}
FOCUSED=0x{{color4 | saturate(-0.2) | strip}}
UNFOCUSED=0x{{color8 | strip}}

riverctl background-color $BACKGROUND
riverctl border-color-focused $FOCUSED
riverctl border-color-unfocused $UNFOCUSED

export RIVER_BACKGROUND=$BACKGROUND
export RIVER_FOCUSED=$FOCUSED
export RIVER_UNFOCUSED=$UNFOCUSED
