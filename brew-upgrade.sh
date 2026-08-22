#!/bin/zsh
set -e

echo
echo "===== $(date '+%Y-%m-%d %H:%M:%S %Z') ====="
/opt/homebrew/bin/brew update
/opt/homebrew/bin/brew upgrade
