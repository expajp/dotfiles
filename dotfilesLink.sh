#!/bin/sh

# copy switch.sh
mkdir ~/bin
cp ~/dotfiles/switch.sh ~/bin/switch.sh
chmod 755 ~/bin/switch.sh

# dotfiles
ln -sf ~/dotfiles/.zshrc ~/.zshrc
touch ~/.zshrc.local

ln -sf ~/dotfiles/.emacs ~/.emacs
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.hyper.js  ~/.hyper.js
