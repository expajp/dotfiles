# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# mise
eval "$(mise activate zsh)"

# PATH
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export PATH

# zsh-abbr
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh

# zplug
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

# https://github.com/olets/zsh-autosuggestions-abbreviations-strategy/commit/3ce24713e4a49f9a5060d9016d35f3cd048d1c74
zplug "olets/zsh-autosuggestions-abbreviations-strategy", at:3ce24713e4a49f9a5060d9016d35f3cd048d1c74, frozen:1

if ! zplug check --verbose; then zplug install; fi
zplug load #--verbose

# zmv
autoload -Uz zmv
abbr -S zmv='noglob zmv -W' >/dev/null

# zsh-completions, zsh-autosuggestions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit && compinit
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh
fi
ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history completion)

# history (prezto modules/history 相当)
setopt BANG_HIST              # 展開時に '!' 文字を特別扱いする
setopt EXTENDED_HISTORY       # ':start:elapsed;command' 形式でヒストリファイルに書き込む
setopt SHARE_HISTORY          # すべてのセッションでヒストリを共有する
setopt HIST_EXPIRE_DUPS_FIRST # ヒストリ削減時は重複エントリを優先的に削除する
setopt HIST_IGNORE_DUPS       # 直前と同じコマンドはヒストリに記録しない
setopt HIST_IGNORE_ALL_DUPS   # 重複するコマンドは古い方を削除する
setopt HIST_FIND_NO_DUPS      # 検索済みのイベントを再表示しない
setopt HIST_IGNORE_SPACE      # スペースで始まるコマンドはヒストリに記録しない
setopt HIST_SAVE_NO_DUPS      # 重複するコマンドをヒストリファイルに書き込まない
setopt HIST_VERIFY            # ヒストリ展開後すぐに実行しない
setopt HIST_BEEP              # 存在しないヒストリにアクセスしたときにビープ音を鳴らす

HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zsh_history}" # ヒストリファイルのパス
HISTSIZE=10000                                         # 内部ヒストリに保存する最大イベント数
SAVEHIST=$HISTSIZE                                     # ヒストリファイルに保存する最大イベント数

abbr -S history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head" >/dev/null

# directory (prezto modules/directory 相当)
setopt AUTO_CD              # cd なしでディレクトリ名だけで移動する
setopt AUTO_PUSHD           # cd 時に元のディレクトリをスタックに積む
setopt PUSHD_IGNORE_DUPS    # スタックに重複を記録しない
setopt PUSHD_SILENT         # pushd / popd 後にスタックを表示しない
setopt PUSHD_TO_HOME        # 引数なしの pushd でホームディレクトリへ移動する
setopt CDABLE_VARS          # 変数に格納されたパスへ cd できる
setopt MULTIOS              # 複数のディスクリプタへ出力できる
setopt EXTENDED_GLOB        # 拡張グロブ構文を使用する
unsetopt CLOBBER            # > や >> で既存ファイルを上書きしない
                            # 上書きする場合は >! や >>! を使う

abbr -S -- -='cd -' >/dev/null
abbr -S d='dirs -v' >/dev/null
for index ({1..9}) abbr -S "$index"="cd +${index}" >/dev/null; unset index

# 色設定
autoload -Uz colors && colors

# 新しくインストールしたコマンドをすぐに補完候補に反映する
zstyle ":completion:*:commands" rehash 1

# プロンプト
export CLICOLOR=1

function left-prompt {
  name_t='179m%}'      # ユーザー名テキスト色
  name_b='000m%}'    # ユーザー名背景色
  path_t='255m%}'     # パステキスト色
  path_b='031m%}'   # パス背景色
  arrow='087m%}'   # 矢印色
  text_color='%{\e[38;5;'    # テキスト色を設定
  back_color='%{\e[30;48;5;' # 背景色を設定
  reset='%{\e[0m%}'   # リセット
  sharp='❯'     # セクション区切り

  user="${back_color}${name_b}${text_color}${name_t}"
  dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${user}%n%#@%m${text_color}${path_b}${sharp} ${dir}%~ ${reset}\n${text_color}${arrow}→ ${reset}"
}

PROMPT=`left-prompt` 

# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status

  branch='⎇'
  color='%{\e[38;5;' #  文字色を設定
  green='114m%}'
  red='001m%}'
  yellow='227m%}'
  blue='033m%}'
  reset='%{\e[0m%}'   # リセット

  if [ ! -e  ".git" ]; then
    # git 管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全て commit されてクリーンな状態
    branch_status="${color}${green}${branch}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # git 管理されていないファイルがある状態
    branch_status="${color}${red}${branch}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git add されていないファイルがある状態
    branch_status="${color}${red}${branch}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commit されていないファイルがある状態
    branch_status="${color}${yellow}${branch}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "${color}${red}${branch}!(no branch)${reset}"
    return
  else
    # 上記以外の状態の場合
    branch_status="${color}${blue}${branch}"
  fi
  echo "${branch_status} $branch_name${reset}"
}

setopt prompt_subst

RPROMPT='`rprompt-git-current-branch`'

# abbrs
abbr -S greset='git reset --hard HEAD' >/dev/null
abbr -S switch='switch.sh' >/dev/null
abbr -S dtfmt='+\"%Y%m%d\"' >/dev/null
abbr -S currentbranch='git rev-parse --abbrev-ref HEAD | pbcopy && pbpaste' >/dev/null
abbr -S restore='git restore .' >/dev/null

add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

precmd() {
  add_newline
}

# .zshrc.local というファイルが存在する場合のみ読み込む
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
