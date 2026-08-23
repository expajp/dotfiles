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

# mise
if ! command -v mise >/dev/null 2>&1; then
  echo "mise がインストールされていません。先に mise をインストールしてください。"
  echo "  https://mise.jdx.dev/getting-started.html"
else
  mkdir -p ~/.config/mise
  ln -sf ~/dotfiles/mise.toml ~/.config/mise/config.toml
  ln -sf ~/dotfiles/mise.lock ~/.config/mise/mise.lock
fi
