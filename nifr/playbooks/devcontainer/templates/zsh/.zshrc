# export LANG=en_US.utf-8
# export LC_ALL=en_US.utf-8
KEYTIMEOUT=1

[[ ! -z "${GNOME_TERMINAL_SCREEN}" ]] && [[ -z "${TMUX}" ]] && export TERM='gnome-256color'
[[ ! -z "${TMUX}" ]] && export TERM='tmux-256color'

if ! (( $+commands[brew] )); then
  hash -d linuxbrew=/home/linuxbrew
fi

# make $fpath a unique array to prevent duplicate entries
# see: https://unix.stackexchange.com/a/62599
typeset -U fpath
fpath=(
  ~/.local/usr/share/zsh/functions
  ~/.local/usr/share/zsh/completions
  ~/.local/share/zsh/functions
  ~/.local/share/zsh/completions
  ~linuxbrew/.linuxbrew/share/zsh/site-functions
  ~linuxbrew/.linuxbrew/share/zsh-completions
  $fpath
)
# TODO: FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
# TODO: Remove non existant directories from $fpath

autoload -U +X bashcompinit; bashcompinit
autoload -Uz compinit; compinit

# make $path a unique array to prevent duplicate entries
# see: https://unix.stackexchange.com/a/62599
typeset -U path
path=(
  ~/.local/usr/bin
  ~/.pyenv/bin
  ~/.local/lib/cargo/bin
  ~/.local/lib/rustup/bin
  ~/.local/bin
  ~linuxbrew/.linuxbrew/bin
  ~linuxbrew/.linuxbrew/sbin
  $path
)
# TODO: Remove non existant directories from $path

# TODO: set up manpath, infopath

# zsh/terminfo requires a valid terminfo database.
# * install the `ncurses-term` package on debian based systems
zmodload zsh/terminfo # enable $terminfo[]
zmodload zsh/complist

# always rehash before completing.
# this slows down performance but might not be noticable on modern systems
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu select
# enable shift+tab to cycle completions backwards
bindkey -M menuselect "${terminfo[kcbt]}" reverse-menu-complete
unsetopt menu_complete # insert first completion on tab
setopt automenu
# don't beep on every completion
unsetopt listbeep

# ctrl+u - remove all characters until beginning of line (default: kill whole line)
# Use Ctrl+k to kill the complete line (bound to zle function "kill-line")
bindkey '^U' backward-kill-line

# ctrl+z - toggle background jobs
# via: https://serverfault.com/a/225821
ctrlz () {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N ctrlz
bindkey '^Z' ctrlz

# 'history' in zsh is 'fc -l'
# Usage: fc [flags] [start_number]
#
# Example: history kubectl
# Output:
#    2  2020-01-08 06:38  0:00  kubectl get namespaces
#    3  2020-01-08 06:38  0:00  kubectl -n production get pods
#
# -i : add ISO8601 timestamps (i.e. 2020-01-08 07:33)
# -D : show elapsed time (i.e. 02:00)
# -m <pattern> : match pattern
#
# TODO support `history -c`
history() {
  fc -lDim "*$@*" 1
}

# the "parameter module" provides the $options variable
zmodload zsh/parameter
options() {
  for k in "${(@k)options}"; do
    echo "$k  ${options[$k]}"
  done \
  | column -t \
  | sort
}

env () {
  # invoke the original `env` command if stdout is not attached to a tty
  # or stdout is attached to a pipe and ensure to match the exit code.
  if [[ ! -t 1 && ! -p /dev/stdout ]] ; then
    command env "${@}";

    return $?;
  fi

  # sort the environment variables alphabetically if no arguments are given
  if [ $# -eq 0 ]; then
    command env | sort;

    return $?;
  fi

  # invoke the original command if arguments are given
  # TODO: enhance with fzf + preview
  command env "${@}";

  return $?;
}

HISTFILE=~/.local/share/zsh/history/histfile
[ ! -d "${HISTFILE}" ] && mkdir -p "${HISTFILE:h}"
HISTSIZE=99999
SAVEHIST=99999
setopt inc_append_history
setopt histignorespace
setopt hist_find_no_dups
unsetopt hist_ignore_all_dups

setopt interactivecomments

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
# $terminfo[kcud1] = arrow down
# $terminfo[kcuu1] = arrow up
#
# TIP: print all entries & their escape sequences in $terminfo
#   printf '%q => %q\n' "${(@kv)terminfo}"
bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search

# ESC-up|down - move lines up/down in multi-line commands
#
# This only works for lines that exceed $COLUMNS and get wrapped by zsh.
#
# * does NOT work for shorter lines added with '\' -> Enter
# * Use Meta+Enter schedule a line for execution instead of using '\' -> Enter
#
# see: https://unix.stackexchange.com/q/258787
_physical_up_line()   { zle backward-char -n $COLUMNS }
_physical_down_line() { zle forward-char  -n $COLUMNS }
zle -N           physical-up-line _physical_up_line
zle -N           physical-down-line _physical_down_line
bindkey "^[^[[A" physical-up-line
bindkey "^[^[[B" physical-down-line

# META-e - edit current command in $EDITOR
autoload -Uz  edit-command-line
zle -N        edit-command-line
bindkey '\ee' edit-command-line

# META-q - save current line & resume after next command
# see: https://sgeb.io/posts/2016/11/til-bash-zsh-half-typed-commands/
bindkey '^[q' push-line-or-edit

# META-m - toggle & insert previous word(s) from past commands
# Use in combination with Ctrl+. (insert-last-word)
autoload -Uz  copy-earlier-word
zle -N        copy-earlier-word
bindkey "^[m" copy-earlier-word

# enable C-<Arrow_Left> and C-<Arrow_Right>
bindkey ";5C" forward-word
bindkey ";5D" backward-word

# For our macOS users
if (( $+commands[xsel] )); then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
fi


(( $+commands[starship] )) && source <(starship init zsh)

(( $+commands[fasd] )) && source <(fasd --init auto)
(( $+commands[thefuck] )) && source <(thefuck --alias)
(( $+commands[direnv] )) && source <(direnv hook zsh)

if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate snazzy)"
fi

if (( $+commands[exa] )); then
  alias ll='exa --group --time-style long-iso --group-directories-first --long --all --git --classify'
fi

alias grep='grep -i --color'

(( $+commands[pip] )) && source <(pip completion --zsh)
(( $+commands[pyenv] )) && source <(pyenv init -)
# pipenv --completion was DEPRECATED
# (( $+commands[pipenv] )) && source <(pipenv --completion)
(( $+commands[pipenv] )) && source <(_PIPENV_COMPLETE=zsh_source pipenv)

if (( $+commands[poetry] )); then
  poetry completions zsh > ~/.local/share/zsh/completions/_poetry
fi

(( $+commands[kubectl] )) && source <(kubectl completion zsh)
(( $+commands[helm] )) && source <(helm completion zsh)

(( $+commands[npm] )) && source <(npm completion)

(( $+commands[kitty] )) && source <(kitty + complete setup zsh)

(( $+commands[vault] )) && complete -o nospace -C "$(which vault)" vault
(( $+commands[terraform] )) && complete -o nospace -C "$(which terraform)" terraform
(( $+commands[nomad] )) && complete -o nospace -C "$(which nomad)" nomad

if [[ -d /snap/google-cloud-sdk/current/bin ]]; then
  path=(/snap/google-cloud-sdk/current/bin $path)

  if [[ -r /snap/google-cloud-sdk/current/completion.zsh.inc ]]; then
    source /snap/google-cloud-sdk/current/completion.zsh.inc
  fi
fi

# plugin loader
#
# see: https://github.com/romkatv/zsh-defer
() {
  builtin emulate -L zsh
  setopt +o no_match extendedglob no_aliases

  [ ! -d ~/.local/share/zsh/plugins ] && return 0

  local normal_plugins=(
    ~/.local/share/zsh/plugins/***/***.plugin.zsh~*.defer.plugin.zsh(N.)
  )

  local deferred_plugins=(
    ~/.local/share/zsh/plugins/***/***.defer.plugin.zsh(N.)
  )

  for plugin in $normal_plugins; do
    source "${plugin}"
  done

  if [[ $+commands[zsh-defer] ]]; then
    for deferred_plugin in $deferred_plugins; do
      zsh-defer source "${deferred_plugin}"
    done

    return 0
  fi

  for deferred_plugin in $deferred_plugins; do
    source "${deferred_plugin}"
  done
}

(( $+commands[dpkg] )) && alias dpkg='sudo dpkg'

# TODO: sub-commands failing:
# E: Command line option 'y' [from -y] is not understood in combination with the other options.
#
# * "apt list"
# * "apt show"
(( $+commands[apt] )) && alias apt='sudo apt -y'

(( $+commands[apt-get] )) && alias apt-get='sudo apt-get -y'
(( $+commands[apt-mark] )) && alias apt-mark='sudo apt-mark'
(( $+commands[apt-key] )) && alias apt-key='sudo apt-key'

(( $+commands[aptitude] )) && alias aptitude='sudo aptitude'

(( $+commands[add-apt-repository] )) && alias add-apt-repository='sudo add-apt-repository'

(( $+commands[snap] )) && alias snap='sudo snap'
(( $+commands[systemctl] )) && alias systemctl='sudo systemctl'

(( $+commands[kustomize] )) && complete -o nospace -C "$(which kustomize)" kustomize

# ignore commands from history
alias cd=' cd'
alias ls=' LC_ALL=c ls --group-directories-first --human-readable --color --classify'

# TODO: debian buster default ~/.bashrc
# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# homebrew: fasd
if (( $+commands[fasd] )); then
  eval "$(fasd --init auto)"
  alias a='fasd -a'        # any
  alias s='fasd -si'       # show / search / select
  alias d='fasd -d'        # directory
  alias f='fasd -f'        # file
  alias sd='fasd -sid'     # interactive directory selection
  alias sf='fasd -sif'     # interactive file selection
  alias z='fasd_cd -d'     # cd, same functionality as j in autojump
  alias zz='fasd_cd -d -i' # cd with interactive selection
fi

# suffix aliases
alias -s yml="${EDITOR}"
alias -s json="${EDITOR}"

# COPY/PASTE magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# bind "thefuck-alias"
(( $+commands[thefuck] )) && source <(thefuck --alias)

fuck-command-line() {
    local FUCK="$(THEFUCK_REQUIRE_CONFIRMATION=0 thefuck $(fc -ln -1 | tail -n 1) 2> /dev/null)"
    [[ -z $FUCK ]] && echo -n -e "\a" && return
    BUFFER=$FUCK
    zle end-of-line
}
zle -N fuck-command-line
# Defined shortcut keys: [Esc] [Esc]
bindkey -M emacs '\e\e' fuck-command-line
bindkey -M vicmd '\e\e' fuck-command-line

# Variables for Rust
export CARGO_HOME="${HOME}/.local/lib/cargo"
export RUSTUP_HOME="${HOME}/.local/lib/rustup"

# Tries to activate pipx completion
(( $+commands[register-python-argcomplete] )) && source <(register-python-argcomplete pipx)

# add completion to the "aws" command
#
# requires running "bashcompinit" BEFORE as otherwise the "complete" command is
# not available.
AWS_COMPLETER_PATH="$(which aws_completer)"
[ -x "${AWS_COMPLETER_PATH}" ] && complete -C "${AWS_COMPLETER_PATH}" aws
unset AWS_COMPLETER_PATH

# Initialize "hub" (aliases "git" to "hub")
#
# "hub" itself wraps the original "git" command and provides additional
# (mosly GitHub related) sub-commands like i.e.
#
# * `hub browse github/hub issues` -> open https://github.com/github/hub/issues
# * `hub gist create --copy <file>` -> create gist from file & copy URL
#
# see: https://hub.github.com/hub.1.html (full reference)
# see: https://github.com/github/hub
(( $+commands[hub] )) && source <(hub alias -s zsh)

# linuxbrew stuff
# # ls -la $(brew --prefix ruby)/bin
# tmuxinator:
# By default, binaries installed by gem will be placed into:
# /home/linuxbrew/.linuxbrew/lib/ruby/gems/2.7.0/bin
# zsh completions have been installed to:
# /home/linuxbrew/.linuxbrew/share/zsh/site-functions

# command not found handler (default: debian 10 / buster /etc/bash.bashrc)
# if the command-not-found package is installed, use it
# attention: the package requires "lsb-release", "python3*" and "python3-apt"
# if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
# 	function command_not_found_handle {
# 	        # check because c-n-f could've been removed in the meantime
#                 if [ -x /usr/lib/command-not-found ]; then
# 		   /usr/lib/command-not-found -- "$1"
#                    return $?
#                 elif [ -x /usr/share/command-not-found/command-not-found ]; then
# 		   /usr/share/command-not-found/command-not-found -- "$1"
#                    return $?
# 		else
# 		   printf "%s: command not found\n" "$1" >&2
# 		   return 127
# 		fi
# }
# fi

if (( $+commands[brew] )); then
  if [ -f "$(brew --prefix git-extras)/share/git-extras/git-extras-completion.zsh" ]; then
    ln -sf "$(brew --prefix git-extras)/share/git-extras/git-extras-completion.zsh" "$(brew --prefix)/share/zsh/site-functions/_git-extras"
  fi

  # TODO: https://github.com/Homebrew/homebrew-command-not-found
fi

# source a private .zshrc if available (i.e. in a devcontainer or VM)
# this should always stay the LAST statement in this file to allow
# overriding ANY other settings
[ -r ~/private/zsh/.zshrc ] && source ~/private/zsh/.zshrc
