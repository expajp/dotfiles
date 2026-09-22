#!/bin/sh
# `npx skills` の実体として使うラッパー。
# skills CLI には設定ファイルが無いため、このリポジトリで常に使う設定をここで固定する。
#   scope    : プロジェクト（-g を付けない）。常に ~/dotfiles で実行し、
#              lock を ~/dotfiles/skills-lock.json に固定する
#   agents   : universal を指定してスキル実体を .agents/skills/ に置き、
#              .claude/skills/ から相対 symlink を張って Claude Code に読ませる。
#              復元コマンド experimental_install の展開先が .agents/skills/ 固定
#              なので、add の配置もそこに揃えないと両者が食い違う
#   linkMode : symlink（.claude/skills/<name> -> ../../.agents/skills/<name>）
# setup.sh が ~/bin/skills.sh にコピーし、.zshrc の abbr で `npx skills` → `skills.sh`
# に展開される。
# 使い方:
#   skills.sh add <source> -s <skill> [<skill> ...]
#   skills.sh ls | update -p -y | remove <skill> | experimental_install
set -e

cd "$HOME/dotfiles"

LOCK="skills-lock.json"

# skills-lock.json に載っているスキルのうち、.claude/skills/<name> が無いものへ
# ../../.agents/skills/<name> への相対 symlink を張る。Claude Code は
# .agents/skills/ を読まないため、この symlink が無いとスキルが見えない。
link_claude_skills() {
  if [ ! -f "$LOCK" ]; then
    return 0
  fi
  mkdir -p .claude/skills
  sed -n 's/^    "\([^"]*\)": {$/\1/p' "$LOCK" | while read -r name; do
    if [ ! -d ".agents/skills/$name" ]; then
      continue
    fi
    if [ -L ".claude/skills/$name" ]; then
      continue
    fi
    if [ -e ".claude/skills/$name" ]; then
      echo "警告: .claude/skills/$name が実体のディレクトリです。symlink に張り替えるか確認してください。" >&2
      continue
    fi
    ln -sfn "../../.agents/skills/$name" ".claude/skills/$name"
  done
}

if [ $# -eq 0 ]; then
  exec mise exec -- skills --help
fi

cmd="$1"
shift

case "$cmd" in
  add|a|i|install)
    mise exec -- skills add "$@" -a universal -y
    link_claude_skills
    ;;
  experimental_install)
    mise exec -- skills experimental_install "$@"
    link_claude_skills
    ;;
  *)
    exec mise exec -- skills "$cmd" "$@"
    ;;
esac
