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

# claude skills
if ! command -v claude >/dev/null 2>&1; then
  echo "claude がインストールされていません。先に Claude Code をインストールしてください。"
  echo "  https://claude.ai/code"
else
  ln -sf ~/dotfiles/.claude/skills ~/.claude/skills
fi

# mise
if ! command -v mise >/dev/null 2>&1; then
  echo "mise がインストールされていません。先に mise をインストールしてください。"
  echo "  https://mise.jdx.dev/getting-started.html"
else
  mkdir -p ~/.config/mise
  ln -sf ~/dotfiles/mise.toml ~/.config/mise/config.toml
  ln -sf ~/dotfiles/mise.lock ~/.config/mise/mise.lock
fi
