#!/bin/bash

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
    DISTRO=$(sudo cat /etc/os-release | head -1 | sed 's/\(NAME=\|"\)//g')
    if [[ "$DISTRO" == *"Ubuntu"* ]]; then
        if ! command -v fish >/dev/null 2>&1; then
            FISH_DEB="fish_4.2.1-1~$(lsb_release -sc)_$(dpkg --print-architecture).deb"
            sudo apt install libtinfo6 curl -y
            curl --output-dir ~/Downloads -LO https://launchpad.net/~fish-shell/+archive/ubuntu/release-4/+files/$FISH_DEB \
                && sudo dpkg -i ~/Downloads/$FISH_DEB \
                && rm -rf ~/Downloads/$FISH_DEB
        fi
        sudo apt update && sudo apt -y upgrade
        # install bat
        sudo apt install -y bat
        # install eza
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
        # install fzf
        sudo apt install fzf
        # install git
        sudo apt install git-all
        # install ripgrep
        sudo apt install ripgrep
        # install vim
        sudo apt install -y vim
        # install tmux
        sudo apt install -y tmux
        # install dependencies for alacritty
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | bash -s -- -y
        sudo apt install cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 build-essential

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
    # Install alacritty
    git clone https://github.com/alacritty/alacritty.git
    cd alacritty
    cargo build --release
    infocmp alacritty
    sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
    cd ..
    rm -rf alacritty
fi

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

