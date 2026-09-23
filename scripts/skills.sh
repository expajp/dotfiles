#!/bin/sh
# `npx skills` の実体として使うラッパー。
# skills CLI には設定ファイルが無いため、このリポジトリで常に使う設定をここで固定する。
#   scope    : プロジェクト（-g を付けない）。常に ~/dotfiles で実行し、
#              lock を ~/dotfiles/skills-lock.json に固定する
#   agents   : universal を指定してスキル実体を ~/dotfiles/.agents/skills/ に置く。
#              復元コマンド experimental_install の展開先が .agents/skills/ 固定
#              なので、add の配置もそこに揃えないと両者が食い違う
#   linkMode : symlink（~/.claude/skills/<name> -> ~/dotfiles/.agents/skills/<name>）
#
# スキルの置き場所は 2 系統に分かれる。
#   自作スキル : ~/dotfiles/.claude/skills/ に実体（git 管理）。symlink は setup.sh が張る
#   外部スキル : ~/dotfiles/.agents/skills/ に実体（git 管理外）。symlink はこのスクリプトが張る
# どちらも ~/.claude/skills/ から symlink で束ねる。~/.claude/skills 自体は実ディレクトリ。
#
# setup.sh が ~/bin/skills.sh にコピーし、.zshrc の abbr で `npx skills` → `skills.sh`
# に展開される。
# 使い方:
#   skills.sh add <source> -s <skill> [<skill> ...]
#   skills.sh ls | update -p -y | remove <skill> | experimental_install
set -e

cd "$HOME/dotfiles"

LOCK="skills-lock.json"
CLAUDE_SKILLS="$HOME/.claude/skills"

# skills-lock.json に載っている外部スキル名を 1 行ずつ出す。
lock_skill_names() {
  if [ ! -f "$LOCK" ]; then
    return 0
  fi
  sed -n 's/^    "\([^"]*\)": {$/\1/p' "$LOCK"
}

# skills CLI を静かに実行する。
# CLI はスキル 1 件ごとに Source / Cloning / Summary / Security / Installed の
# バナーを出すため、そのまま流すと復元だけで 400 行を超える。成功時は結果行
# （✓ <skill> (copied)）だけに絞り、失敗したときは原因が追えるよう全文を出す。
# lock の件数より結果行が少ない場合も、取りこぼしとみなして全文を出す。
run_skills_quietly() {
  out=$(mise exec -- skills "$@" 2>&1) && status=0 || status=$?

  if [ "$status" -ne 0 ]; then
    printf '%s\n' "$out" >&2
    return "$status"
  fi

  # 枠線と前後の空白を落として結果行だけ残す
  printf '%s\n' "$out" \
    | grep '✓' \
    | sed -e 's/│//g' -e 's/^[[:space:]]*/  /' -e 's/[[:space:]]*$//' \
    || true

  installed=$(printf '%s\n' "$out" | grep -c '✓' || true)
  expected=$(lock_skill_names | wc -l | tr -d ' ')
  if [ "$installed" -lt "$expected" ]; then
    echo "警告: skills-lock.json の $expected 件に対し $installed 件しか結果が出ていません。全文を出します。" >&2
    printf '%s\n' "$out" >&2
  fi
}

# skills-lock.json に載っている外部スキルについて、~/.claude/skills/<name> から
# ~/dotfiles/.agents/skills/<name> への symlink を張る。あわせて、実体が消えた
# スキルのリンク切れ symlink を片付ける。
link_claude_skills() {
  mkdir -p "$CLAUDE_SKILLS"

  # 実体が消えたスキルの symlink を外す。壊れたリンクだけが対象で、
  # 実ファイル・実ディレクトリには触らない。
  for link in "$CLAUDE_SKILLS"/*; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
      rm -f "$link"
    fi
  done

  if [ ! -f "$LOCK" ]; then
    return 0
  fi

  lock_skill_names | while read -r name; do
    if [ ! -d ".agents/skills/$name" ]; then
      continue
    fi
    if [ -L "$CLAUDE_SKILLS/$name" ]; then
      continue
    fi
    if [ -e "$CLAUDE_SKILLS/$name" ]; then
      echo "警告: $CLAUDE_SKILLS/$name が symlink ではありません。中身を確認してください。" >&2
      continue
    fi
    ln -sfn "$HOME/dotfiles/.agents/skills/$name" "$CLAUDE_SKILLS/$name"
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
    run_skills_quietly experimental_install "$@"
    link_claude_skills
    ;;
  remove|rm|r|update|upgrade)
    mise exec -- skills "$cmd" "$@"
    link_claude_skills
    ;;
  *)
    exec mise exec -- skills "$cmd" "$@"
    ;;
esac
