#!/bin/sh

riverctl background-color 0x{{color2 | blend(color0) | blend(color0) | strip}}
riverctl border-color-focused 0x{{color4 | saturate(-0.2) | strip}}
riverctl border-color-unfocused 0x{{color8 | strip}}
