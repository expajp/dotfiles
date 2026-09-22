#!/bin/sh
# 新しい Mac のセットアップを一括実行する。
# Homebrew のインストールのみ、セキュリティ上の理由から自動実行はせず手動対応を促す。
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "===== Homebrew ====="
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew がインストールされていません。"
  echo "セキュリティ上の理由から、このスクリプトは Homebrew のインストールを自動実行しません。"
  echo "以下の公式インストーラーを手動で実行してから、このスクリプトを再実行してください。"
  echo ""
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo ""
  echo "  https://brew.sh"
  exit 1
fi
echo "Homebrew は導入済みです。"

echo ""
echo "===== ~/dotfiles のリンク ====="
if [ -e "$HOME/dotfiles" ] || [ -L "$HOME/dotfiles" ]; then
  if [ "$HOME/dotfiles" -ef "$DOTFILES_DIR" ]; then
    echo "~/dotfiles は既にこのリポジトリを指しています。"
  else
    echo "エラー: ~/dotfiles が既に存在し、このリポジトリ ($DOTFILES_DIR) とは異なる場所を指しています。"
    echo "内容を確認の上、手動で対処してください。"
    exit 1
  fi
else
  ln -s "$DOTFILES_DIR" "$HOME/dotfiles"
  echo "~/dotfiles -> $DOTFILES_DIR にリンクしました。"
fi

echo ""
echo "===== brew の自動アップグレード設定 ====="
# ~/.local/bin の存在確認
if [ -d ~/.local/bin ]; then
  echo "~/.local/bin は既に存在します。"
else
  mkdir -p ~/.local/bin
  echo "~/.local/bin を作成しました。"
fi

# copy brew-upgrade.sh
# 旧バージョンのスクリプトが symlink で配置していた場合、コピー元と同一ファイルに
# なってしまい cp が失敗するため、先に既存のリンク/ファイルを削除しておく
rm -f ~/.local/bin/brew-upgrade
cp -f ~/dotfiles/brew-upgrade.sh ~/.local/bin/brew-upgrade
chmod 755 ~/.local/bin/brew-upgrade

# copy plist to LaunchAgents（パスはコピー後に実際の $HOME へ書き換える）
# 旧バージョンのスクリプトが symlink で配置していた場合、コピー元と同一ファイルに
# なってしまい cp が失敗するため、先に既存のリンク/ファイルを削除しておく
rm -f ~/Library/LaunchAgents/local.homebrew.upgrade.plist
cp -f ~/dotfiles/local.homebrew.upgrade.plist ~/Library/LaunchAgents/local.homebrew.upgrade.plist
# -i の書式がBSD sedとGNU sedで異なるため、両対応できる -i.bak 形式を使う
sed -i.bak "s|__HOME__|$HOME|g" ~/Library/LaunchAgents/local.homebrew.upgrade.plist
rm -f ~/Library/LaunchAgents/local.homebrew.upgrade.plist.bak

# register LaunchAgent
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/local.homebrew.upgrade.plist 2>/dev/null || true
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.homebrew.upgrade.plist

echo ""
echo "===== Brewfile からパッケージをインストール ====="
brew bundle --file="$HOME/dotfiles/Brewfile"

echo ""
echo "===== dotfiles のシンボリックリンクを作成 ====="
# copy switch.sh
mkdir -p ~/bin
# 旧バージョンのスクリプトが symlink で配置していた場合、コピー元と同一ファイルに
# なってしまい cp が失敗するため、先に既存のリンク/ファイルを削除しておく
rm -f ~/bin/switch.sh
cp -f ~/dotfiles/switch.sh ~/bin/switch.sh
chmod 755 ~/bin/switch.sh

# copy skills.sh（npx skills の実体。.zshrc の abbr で展開される）
# 旧バージョンのスクリプトが symlink で配置していた場合、コピー元と同一ファイルに
# なってしまい cp が失敗するため、先に既存のリンク/ファイルを削除しておく
rm -f ~/bin/skills.sh
cp -f ~/dotfiles/scripts/skills.sh ~/bin/skills.sh
chmod 755 ~/bin/skills.sh

# GNU tools へのシンボリックリンク
ln -sfn `which gawk` $HOME/bin/awk
ln -sfn `which gsed` $HOME/bin/sed
ln -sfn `which gtar` $HOME/bin/tar
ln -sfn `which ggrep` $HOME/bin/grep

# dotfiles
ln -sfn ~/dotfiles/.zshrc ~/.zshrc
touch ~/.zshrc.local

ln -sfn ~/dotfiles/.emacs ~/.emacs
ln -sfn ~/dotfiles/.gitconfig ~/.gitconfig
ln -sfn ~/dotfiles/.hyper.js  ~/.hyper.js

# mise（node と skills CLI もここで入る）
if ! command -v mise >/dev/null 2>&1; then
  echo "mise がインストールされていません。先に mise をインストールしてください。"
  echo "  https://mise.jdx.dev/getting-started.html"
else
  mkdir -p ~/.config/mise
  ln -sfn ~/dotfiles/mise.toml ~/.config/mise/config.toml
  ln -sfn ~/dotfiles/mise.lock ~/.config/mise/mise.lock
  mise trust ~/dotfiles/mise.toml
  mise install
fi

# claude skills
# 自作スキルは ~/dotfiles/.claude/skills/ に実体があり、外部スキルは
# skills-lock.json から .agents/skills/ に復元する。.claude/skills/<name> は
# ../../.agents/skills/<name> への相対 symlink としてコミット済み。
if ! command -v claude >/dev/null 2>&1; then
  echo "claude がインストールされていません。先に Claude Code をインストールしてください。"
  echo "  https://claude.ai/code"
elif ! mise exec -- skills --version >/dev/null 2>&1; then
  echo "skills CLI が見つかりません。mise install が成功しているか確認してください。"
else
  ln -sfn ~/dotfiles/.claude/skills ~/.claude/skills
  ~/bin/skills.sh experimental_install
fi

echo ""
echo "===== セットアップ完了 ====="
