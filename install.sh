#!/bin/bash
set -euo pipefail

# Formac only
if [ "$(uname)" == "Darwin" ]; then
    # install HomeBrew
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
        # install dependencies for alacritty
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | bash -s -- -y
        . "$HOME/.cargo/env"
        fish -c "source $HOME/.cargo/env.fish"
        sudo apt install -y cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 build-essential

    fi
    if [[ "$DISTRO" == *"Fedora"* ]]; then
        sudo dnf update -y
        sudo dnf install fish fzf ripgrep vim tmux @development-tools -y
        # install rustc + cargo
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | bash -s -- -y
        . "$HOME/.cargo/env"
        fish -c "source $HOME/.cargo/env.fish"
        cargo install eza
        # install dependencies for alacritty
        sudo dnf install cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ -y
    fi
    # Install alacritty (disabled — using Ghostty)
    # if ! command -v alacritty &> /dev/null
    # then
    #     git clone https://github.com/alacritty/alacritty.git
    #     cd alacritty
    #     cargo build --release
    #     if [[ $(infocmp alacritty | grep "no match") == *"no match"* ]]; then
    #         sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
    #     fi
    #     sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
    #     sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    #     sudo desktop-file-install extra/linux/Alacritty.desktop
    #     sudo update-desktop-database
    #     cd ..
    #     rm -rf alacritty
    # fi
    # # Add my default config to alacritty
    # ./alacritty_config.sh

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
./ghostty_config.sh

# fish functions (incl. our prompt, which needs the Nerd Font installed above)
mkdir -p ~/.config/fish/functions
cp ./fish/functions/*.fish ~/.config/fish/functions/

# tmux plugin
if [ "$(ls ~/.tmux/plugins | grep tpm)" == "" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

cp ./.tmux.conf ~/.tmux.conf
if [ "$(which fish)" != "" ]; then
    echo -e "set-option -g default-shell $(which fish)" >> ~/.tmux.conf
fi

# gitconfig --global
cp ./git/.gitconfig ~/.gitconfig

# bashrc
if ! grep -q "alias ls=eza" ~/.bashrc; then
    echo -e "alias ls=eza" >> ~/.bashrc
fi

# zshrc
if ! grep -q "alias ls=eza" ~/.zshrc; then
    echo -e "alias ls=eza" >> ~/.zshrc
fi

# fish alias 
fish -c "alias --save ls eza"

# download vim plug plugin
if [ "$(ls ~/.vim/autoload | grep plug.vim)" == "" ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

cp ./vim/.vimrc ~/.vimrc
cp -r ./vim/.vim ~/

