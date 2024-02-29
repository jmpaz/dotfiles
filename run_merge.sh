#!/bin/bash

CHEZMOI_DIR="$HOME/.local/share/chezmoi"
python "$CHEZMOI_DIR/.toml/merge.py"
