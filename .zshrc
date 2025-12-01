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

zplug "modules/history", from:prezto
zplug "modules/directory", from:prezto
zplug "modules/osx", from:prezto
zplug "olets/zsh-autosuggestions-abbreviations-strategy"

if ! zplug check --verbose; then zplug install;fi
zplug load #--verbose

# zmv
autoload -Uz zmv
alias zmv='noglob zmv -W'

# zsh-completions, zsh-autosuggestions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit && compinit
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh
fi
ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history completion)

# colors
autoload -Uz colors && colors

# use newly installed commands instantly
zstyle ":completion:*:commands" rehash 1

# prompt
export CLICOLOR=1

function left-prompt {
  name_t='179m%}'      # user name text clolr
  name_b='000m%}'    # user name background color
  path_t='255m%}'     # path text clolr
  path_b='031m%}'   # path background color
  arrow='087m%}'   # arrow color
  text_color='%{\e[38;5;'    # set text color
  back_color='%{\e[30;48;5;' # set background color
  reset='%{\e[0m%}'   # reset
  sharp='\uE0B0'      # triangle

  user="${back_color}${name_b}${text_color}${name_t}"
  dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${user}%n%#@%m${back_color}${path_b}${text_color}${name_b}${sharp} ${dir}%~${reset}${text_color}${path_b}${sharp}${reset}\n${text_color}${arrow}→ ${reset}"
}

PROMPT=`left-prompt` 

# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status

  branch='\ue0a0'
  color='%{\e[38;5;' #  文字色を設定
  green='114m%}'
  red='001m%}'
  yellow='227m%}'
  blue='033m%}'
  reset='%{\e[0m%}'   # reset

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
