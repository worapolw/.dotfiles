#!/bin/bash
set -euo pipefail
# Deploy the kitty config (Berkeley Mono + fish).
KITTY_CONFIG_PATH="$HOME/.config/kitty"
FISH_PATH=$(which fish)
mkdir -p "$KITTY_CONFIG_PATH"
cat <<EOC > "$KITTY_CONFIG_PATH/kitty.conf"
shell $FISH_PATH
font_family Berkeley Mono
font_size 18
background_opacity 1.0
map cmd+t no_op
EOC
