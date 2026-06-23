#!/bin/bash
set -euo pipefail

RAW="https://raw.githubusercontent.com/worapolw/.dotfiles/main"
dl() { curl -fsSL "$RAW/$1" -o "$2"; }

# macOS only
if [ "$(uname)" == "Darwin" ]; then
    if [ "brew -v" == "" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo >> ~/.zprofile\n    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile\n    eval "$(/opt/homebrew/bin/brew shellenv)"
        fish -c "fish_add_path /opt/homebrew/bin"
    fi
    brew bundle install
elif [ "$(uname)" == "Linux" ]; then
    DISTRO=$(grep '^NAME=' /etc/os-release | sed 's/\(NAME=\|"\)//g')
    if [[ "$DISTRO" == *"Ubuntu"* ]]; then
        # required to download binary
        sudo apt install -y curl
        sudo add-apt-repository -y ppa:fish-shell/release-4
        sudo apt update -y
        sudo apt install -y fish
        sudo apt update -y && sudo apt upgrade -y
        # install bat
        sudo apt install -y bat
        # install eza
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --yes --batch --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update -y
        sudo apt install -y eza
        # install fzf
        sudo apt install -y fzf
        # install git
        sudo apt install -y git-all
        # install ripgrep
        sudo apt install -y ripgrep
        # install vim
        sudo apt install -y vim
        # install tmux
        sudo apt install -y tmux
        # install fastfetch (login banner)
        sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
        sudo apt update -y
        sudo apt install -y fastfetch
        # install dependencies for alacritty
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | bash -s -- -y
        . "$HOME/.cargo/env"
        fish -c "source $HOME/.cargo/env.fish"
        sudo apt install -y cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 build-essential

    fi
    if [[ "$DISTRO" == *"Fedora"* ]]; then
        sudo dnf update -y
        sudo dnf install fish fzf ripgrep vim tmux fastfetch @development-tools -y
        # install rustc + cargo
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | bash -s -- -y
        . "$HOME/.cargo/env"
        fish -c "source $HOME/.cargo/env.fish"
        cargo install eza
        # install dependencies for alacritty
        sudo dnf install cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ -y
    fi

    # install Symbols Nerd Font (terminal icons: OS logos, glyphs)
    mkdir -p "$HOME/.local/share/fonts/SymbolsNerdFont"
    curl -fLo /tmp/NerdFontsSymbolsOnly.tar.xz \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz
    tar -xf /tmp/NerdFontsSymbolsOnly.tar.xz -C "$HOME/.local/share/fonts/SymbolsNerdFont"
    fc-cache -f

    # install Ghostty (per official docs: ghostty.org/docs/install/binary)
    if ! command -v ghostty &> /dev/null; then
        if [[ "$DISTRO" == *"Fedora"* ]]; then
            sudo dnf copr enable -y scottames/ghostty && sudo dnf install -y ghostty
        elif [[ "$DISTRO" == *"Ubuntu"* ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
        fi
    fi
fi

# Add my default config to ghostty (Berkeley Mono + fish)
curl -fsSL "$RAW/ghostty_config.sh" | bash

# fish functions (incl. our prompt + fastfetch login greeting; need the Nerd Font above)
mkdir -p ~/.config/fish/functions
dl fish/functions/fish_prompt.fish   ~/.config/fish/functions/fish_prompt.fish
dl fish/functions/ls.fish            ~/.config/fish/functions/ls.fish
dl fish/functions/fish_greeting.fish ~/.config/fish/functions/fish_greeting.fish

# fastfetch config (login banner theming)
mkdir -p ~/.config/fastfetch
dl fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc

# tmux plugin
if [ "$(ls ~/.tmux/plugins 2>/dev/null | grep tpm)" == "" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
dl .tmux.conf ~/.tmux.conf
if [ "$(which fish)" != "" ]; then
    echo -e "set-option -g default-shell $(which fish)" >> ~/.tmux.conf
fi

# gitconfig --global
dl git/.gitconfig ~/.gitconfig

# bashrc
if ! grep -q "alias ls=eza" ~/.bashrc 2>/dev/null; then
    echo "alias ls=eza" >> ~/.bashrc
fi

# zshrc
if ! grep -q "alias ls=eza" ~/.zshrc 2>/dev/null; then
    echo "alias ls=eza" >> ~/.zshrc
fi

# fish alias
fish -c "alias --save ls eza"

# install Claude Code
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.config/fish/config.fish
    fish -c "source ~/.config/fish/config.fish"
fi

# Claude Code status line config
mkdir -p ~/.claude
dl claude/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
CLAUDE_SETTINGS=~/.claude/settings.json
if [ -f "$CLAUDE_SETTINGS" ]; then
    tmp=$(mktemp)
    jq '. * {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$CLAUDE_SETTINGS" > "$tmp" && mv "$tmp" "$CLAUDE_SETTINGS"
else
    dl claude/settings.json "$CLAUDE_SETTINGS"
fi

# vim-plug
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
dl vim/.vimrc ~/.vimrc
mkdir -p ~/.vim/after/plugin ~/.vim/after/ftplugin
dl vim/.vim/after/plugin/vim-airline-themes.vim ~/.vim/after/plugin/vim-airline-themes.vim
dl vim/.vim/after/plugin/fzf.vim                ~/.vim/after/plugin/fzf.vim
dl vim/.vim/after/ftplugin/typescript.vim       ~/.vim/after/ftplugin/typescript.vim
dl vim/.vim/after/ftplugin/typescriptreact.vim  ~/.vim/after/ftplugin/typescriptreact.vim
dl vim/.vim/after/ftplugin/rust.vim             ~/.vim/after/ftplugin/rust.vim
