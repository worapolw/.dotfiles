#!/bin/bash
set -euo pipefail

RAW="https://raw.githubusercontent.com/worapolw/.dotfiles/main"
dl() { curl -fsSL "$RAW/$1" -o "$2"; }

# macOS only
if [ "$(uname)" == "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon -> /opt/homebrew, Intel -> /usr/local
        BREW_BIN=/opt/homebrew/bin/brew
        [ -x "$BREW_BIN" ] || BREW_BIN=/usr/local/bin/brew
        echo >> ~/.zprofile
        echo "eval \"\$($BREW_BIN shellenv)\"" >> ~/.zprofile
        eval "$($BREW_BIN shellenv)"
    fi
    # Brewfile isn't on disk in a curl | bash run, so download it first
    dl Brewfile /tmp/Brewfile
    brew bundle install --file=/tmp/Brewfile
    # fish only exists after the bundle, so add brew to its PATH here
    fish -c "fish_add_path $(brew --prefix)/bin"
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
        sudo apt install -y cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 build-essential

    fi
    if [[ "$DISTRO" == *"Fedora"* ]]; then
        sudo dnf update -y
        sudo dnf install fish fzf ripgrep vim tmux fastfetch eza @development-tools -y
        # install dependencies for alacritty
        sudo dnf install cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ -y
    fi

    # install Symbols Nerd Font (terminal icons: OS logos, glyphs)
    mkdir -p "$HOME/.local/share/fonts/SymbolsNerdFont"
    curl -fLo /tmp/NerdFontsSymbolsOnly.tar.xz \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz
    tar -xf /tmp/NerdFontsSymbolsOnly.tar.xz -C "$HOME/.local/share/fonts/SymbolsNerdFont"
    fc-cache -f

    # install foot (Wayland terminal)
    if ! command -v foot &> /dev/null; then
        if [[ "$DISTRO" == *"Fedora"* ]]; then
            sudo dnf install -y foot
        elif [[ "$DISTRO" == *"Ubuntu"* ]]; then
            sudo apt install -y foot
        fi
    fi
fi


# Deploy terminal config (Berkeley Mono + fish)
if [ "$(uname)" == "Darwin" ]; then
    curl -fsSL "$RAW/kitty_config.sh" | bash
else
    curl -fsSL "$RAW/foot_config.sh" | bash
    # make foot the default terminal + hide the server/client launchers
    mkdir -p ~/.local/share/applications
    printf 'foot.desktop\n' > ~/.config/xdg-terminals.list
    fish -c "set -Ux TERMINAL foot"
    sudo update-alternatives --set x-terminal-emulator /usr/bin/foot || true
    for f in foot-server footclient; do
        cp "/usr/share/applications/$f.desktop" ~/.local/share/applications/ 2>/dev/null \
            && printf 'NoDisplay=true\n' >> ~/.local/share/applications/$f.desktop
    done
    update-desktop-database ~/.local/share/applications 2>/dev/null || true
fi

# install mise (installs to ~/.local/bin, which may not be on PATH yet)
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise &> /dev/null; then
    curl -fsSL https://mise.run | sh
fi

activation='eval "$(mise activate bash)"'
grep -qxF "$activation" ~/.bashrc 2>/dev/null || printf '%s\n' "$activation" >> ~/.bashrc

mkdir -p ~/.config/fish
activation='mise activate fish | source'
grep -qxF "$activation" ~/.config/fish/config.fish 2>/dev/null || printf '%s\n' "$activation" >> ~/.config/fish/config.fish

# mise shell completion
mise completion bash --install
mise completion fish --install

# fish functions (incl. our prompt + fastfetch login greeting; need the Nerd Font above)
mkdir -p ~/.config/fish/functions
dl fish/functions/fish_prompt.fish   ~/.config/fish/functions/fish_prompt.fish
dl fish/functions/ls.fish            ~/.config/fish/functions/ls.fish
dl fish/functions/fish_greeting.fish ~/.config/fish/functions/fish_greeting.fish

# fastfetch config (login banner theming) + custom cat logo
mkdir -p ~/.config/fastfetch
dl fastfetch/config.jsonc  ~/.config/fastfetch/config.jsonc
dl fastfetch/cat-logo.txt  ~/.config/fastfetch/cat-logo.txt

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
