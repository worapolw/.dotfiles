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
    if [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
        echo "Ni hao"
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
        # install ghostty
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    fi
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
cp ./.bashrc ~/.bashrc

# zshrc
cp ./.bashrc ~/.zshrc

# fish alias 
cp ./fish/functions/* ~/.config/fish/functions/

# download vim plug plugin
if [ "$(ls ~/.vim/autoload | grep plug.vim)" == "" ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

cp ./vim/.vimrc ~/.vimrc
cp -r ./vim/.vim ~/
