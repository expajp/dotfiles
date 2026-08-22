#!/bin/sh

# copy brew-upgrade.sh
cp ~/dotfiles/brew-upgrade.sh ~/.local/bin/brew-upgrade
chmod 755 ~/.local/bin/brew-upgrade

# link to LaunchAgents
ln -sf ~/dotfiles/local.homebrew.upgrade.plist ~/Library/LaunchAgents/local.homebrew.upgrade.plist

# register LaunchAgent
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.homebrew.upgrade.plist
