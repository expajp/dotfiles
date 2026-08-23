#!/bin/sh
# Update anthropics/skills submodule after reviewing SKILL.md diffs for active skills.

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SUBMODULE_PATH=".claude/vendor/anthropics-skills"

cd "$DOTFILES_DIR" || exit 1

OLD_COMMIT=$(git -C "$SUBMODULE_PATH" rev-parse HEAD)

echo "anthropics/skills の最新を取得中..."
git submodule update --remote "$SUBMODULE_PATH"

NEW_COMMIT=$(git -C "$SUBMODULE_PATH" rev-parse HEAD)

if [ "$OLD_COMMIT" = "$NEW_COMMIT" ]; then
  echo "更新はありません。"
  exit 0
fi

echo ""
echo "コミット: $OLD_COMMIT → $NEW_COMMIT"
echo ""
echo "=== 使用中スキルの SKILL.md 差分 ==="

for skill_link in .claude/skills/*/; do
  skill_name=$(basename "$skill_link")
  diff_output=$(git -C "$SUBMODULE_PATH" diff "$OLD_COMMIT" "$NEW_COMMIT" -- "skills/$skill_name/SKILL.md" 2>/dev/null)
  echo ""
  echo "── $skill_name ──"
  if [ -n "$diff_output" ]; then
    echo "$diff_output"
  else
    echo "(変更なし)"
  fi
done

echo ""
printf "この更新をコミットしますか？ [y/N] "
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
  git add "$SUBMODULE_PATH"
  git commit -m "update anthropics/skills submodule to $NEW_COMMIT"
  echo "コミットしました。"
else
  echo "更新を取り消します..."
  git -C "$SUBMODULE_PATH" checkout "$OLD_COMMIT"
  echo "元のコミット ($OLD_COMMIT) に戻しました。"
fi
