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
cp -r ./vim/.vim ~/.vim
