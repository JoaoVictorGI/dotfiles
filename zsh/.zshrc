autoload -Uz compinit
compinit -u

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

HISTSIZE=7000
SAVEHIST=100000
HISTFILE=~/.zshhistory

source <(fzf --zsh)

set_opts=(
  HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
  NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
  NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
)
for opt in "${set_opts[@]}"; do
  setopt "$opt"
done
unset opt set_opts

export PATH="$PATH:$HOME/.local/bin"
export EDITOR="emacsclient -c -a ''"

alias sudo="doas"
alias l="ls -l"
alias la="ls -lAh --group-directories-first --color=auto"
alias ls="ls -h --group-directories-first --color=auto"

eval "$(starship init zsh)"
eval "$(mise activate zsh)"
