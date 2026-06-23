#!/bin/bash
set -euo pipefail
# Deploy the Ghostty config (Berkeley Mono + fish). Mirrors alacritty_config.sh.
GHOSTTY_CONFIG_PATH="$HOME/.config/ghostty"
FISH_PATH=$(which fish)
mkdir -p "$GHOSTTY_CONFIG_PATH"
cat <<EOF > "$GHOSTTY_CONFIG_PATH/config"
command = $FISH_PATH
font-family = Berkeley Mono
font-size = 18
background-opacity = 1
progress-style = false
EOF
