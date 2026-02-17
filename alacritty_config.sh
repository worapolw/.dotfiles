#!/bin/bash
ALACRITTY_CONFIG_PATH="$HOME/.config/alacritty"
FISH_PATH=$(which fish)
mkdir -p "$ALACRITTY_CONFIG_PATH"
touch "$ALACRITTY_CONFIG_PATH/alacritty.toml"
cat <<EOF > "$ALACRITTY_CONFIG_PATH/alacritty.toml"
[terminal]
shell = "$FISH_PATH"

[font]
size = 16.0
normal = { family = "Berkeley Mono", style = "Regular" }
bold = { family = "Berkeley Mono", style = "Bold" }
italic = { family = "Berkeley Mono", style = "Italic" }
bold_italic = { family = "Berkeley Mono", style = "Bold Italic" }
EOF
