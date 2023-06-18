# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# anyenv
eval "$(anyenv init -)"
eval "$(rbenv init - zsh)"

export PATH

# zplug
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "modules/history", from:prezto
zplug "modules/directory", from:prezto
zplug "modules/osx", from:prezto

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
