#!/bin/bash
set -euo pipefail
# Deploy the foot config (Berkeley Mono + fish).
FOOT_CONFIG_PATH="$HOME/.config/foot"
FISH_PATH=$(which fish)
mkdir -p "$FOOT_CONFIG_PATH"
cat <<EOF > "$FOOT_CONFIG_PATH/foot.ini"
shell=$FISH_PATH
font=Berkeley Mono:size=18
initial-window-mode=fullscreen

[colors]
alpha=1.0
EOF
