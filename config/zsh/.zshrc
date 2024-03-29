# store all plugins to be upgraded
export -Ua PLUGINS_UPGRADE

function zsh-add-plugin ()
{
    PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
    PLUGIN_DIR="$ZDOTDIR/plugins/$PLUGIN_NAME"

    [ ! -d "$PLUGIN_DIR" ] && git clone "https://github.com/$1.git" "$PLUGIN_DIR"

    PLUGINS_UPGRADE+=("${PLUGIN_DIR}")

    if   [ "$2" != "" ] && [ -f $PLUGIN_DIR/$2 ];    then source $PLUGIN_DIR/$2
    elif [ -f $PLUGIN_DIR/$PLUGIN_NAME.plugin.zsh ]; then source $PLUGIN_DIR/$PLUGIN_NAME.plugin.zsh
    elif [ -f $PLUGIN_DIR/$PLUGIN_NAME.zsh ];        then source $PLUGIN_DIR/$PLUGIN_NAME.zsh
    else
        echo "Can't load $PLUGIN_NAME"
    fi
}

function zsh-upgrade ()
{
    local PLUGIN_DIR

    for PLUGIN_DIR in "${PLUGINS_UPGRADE[@]}"
    do
        pushd "${PLUGIN_DIR}" > /dev/null || continue
        printf 'Updating %s\n' "${PLUGIN_DIR}"
        git pull
        printf '\n'
        popd > /dev/null || continue
    done
}

# Function to source files if they exist
# function zsh-add-file ()
# {
#     [ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
# }

# function zsh-add-completion ()
# {
#     PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
#     if [ -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then
#         # For completions
#         completion_file_path=$(ls $ZDOTDIR/plugins/$PLUGIN_NAME/_*)
#         fpath+="$(dirname "${completion_file_path}")"
#         zsh-add-file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh"
#     else
#         git clone "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
#         fpath+=$(ls $ZDOTDIR/plugins/$PLUGIN_NAME/_*)
#         [ -f $ZDOTDIR/.zccompdump ] && $ZDOTDIR/.zccompdump
#     fi
#     completion_file="$(basename "${completion_file_path}")"
#     if [ "$2" = true ] && compinit "${completion_file:1}"
# }

# Unpacking the archive
function ex ()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xvjf $1   ;;
            *.tar.gz)  tar xvzf $1   ;;
            *.tar.xz)  tar xvfJ $1   ;;
            *.bz2)     bunzip2 $1    ;;
            *.rar)     unrar x $1    ;;
            *.gz)      gunzip $1     ;;
            *.tar)     tar xvf $1    ;;
            *.tbz2)    tar xvjf $1   ;;
            *.tgz)     tar xvzf $1   ;;
            *.zip)     unzip $1      ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1       ;;
            *)         echo "'$1' cannot be unpacked with ex()" ;;
        esac
    else
        echo "'$1' is not valid file"
    fi
}

# Packing in the archive
function pk ()
{
    if [ $1 ] ; then
        case $1 in
            tbz)    tar cjvf $2.tar.bz2 $2   ;;
            tgz)    tar czvf $2.tar.gz  $2   ;;
            tar)    tar cpvf $2.tar  $2      ;;
            bz2)    bzip $2                  ;;
            gz)     gzip -c -9 -n $2 > $2.gz ;;
            zip)    zip -r $2.zip $2         ;;
            7z)     7z a $2.7z $2            ;;
            *)      echo "'$1' cannot be packed with pk()" ;;
        esac
    else
        echo "'$1' is not valid file"
    fi
}

mkdir -p ~/.config/zsh/plugins

zsh-add-plugin "zsh-users/zsh-autosuggestions"
zsh-add-plugin "hlissner/zsh-autopair"
zsh-add-plugin "none9632/zsh-sudo"
zsh-add-plugin "zsh-users/zsh-syntax-highlighting"
zsh-add-plugin "djui/alias-tips"

autoload -U colors && colors

PREFIX="λ"
WHITE="%F{#bbc2cf}"
PURPLE="%B%F{#d499e5}"
GREEN="%B%F{#98be65}"
BLUE="%B%F{#51afef}"
ORANGE="%B%F{214}"
GREY="%F{#7b7278}"
BCYAN="%F{#46d9ff}"
END="%{$reset_color%}"

PROMPT="\
${GREY}┌[${END}\
${GREEN}%~${END}\
${GREY}]─[${END}\
${BLUE}%n${END}\
${GREY}]─[${END}\
${ORANGE}%M${END}\
${GREY}]
└>${END} \
${BCYAN}${PREFIX}${END} \
${WHITE}${END}"

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp)

ZSH_HIGHLIGHT_REGEXP+=('\bsudo\b' fg=#e76f51)
ZSH_HIGHLIGHT_REGEXP+=("[\$][a-zA-Z0-9_]*" fg=#5699af)
ZSH_HIGHLIGHT_REGEXP+=("\b(http|https|ftp)://[^\"|\ |'|\$]*\b" fg=#51afef,underline)

ZSH_HIGHLIGHT_STYLES[arg0]='fg=#c792ea'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#e7c07b'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#e7c07b'
ZSH_HIGHLIGHT_STYLES[path]='fg=#98be65'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='none'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#5699af'

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.cache/zsh/history

mkdir -p $HOME/.cache/zsh

# Ignoring repetitive lines in the history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
# setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

export FZF_DEFAULT_COMMAND="fd --type f --color=never --hidden"
export FZF_DEFAULT_OPTS="--bind tab:down --bind btab:up"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"

export FZF_ALT_C_COMMAND='fd --type d --type symlink . --color=never --hidden'
export FZF_ALT_C_OPTS="--preview 'exa -1a --color=always --group-directories-first {} | head -50'"

export FZF_HISTDIR=$HOME/.cache/fzf

FZF_COMPLETION_TRIGGER='hh'

function find_file ()
{
    res="$(find -L . \( -path '*/\*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
        -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m -e --preview='ls -1A {}')"
    LBUFFER+="$res "
    # Needed in order for the highlighting rules to apply
    zle copy-region-as-kill
}
zle -N find_file

bindkey -M vicmd "T" fzf-file-widget
bindkey "^h^h" fzf-cd-widget
bindkey "^[r"  fzf-history-widget
bindkey "^[f"  find_file

autoload -U compinit && compinit

# Added hidden files
_comp_options+=(globdots)

# Use a cache in order to proxy the list of results
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/

# Ignore completion functions for commands you don't have
zstyle ':completion:*:functions' ignored-patterns '_*'

# Persistent rehash
zstyle ':completion:*' rehash true

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zsh-add-plugin "Aloxaf/fzf-tab"

# Needed in order for the highlighting rules to apply
function fix-fzf-tab ()
{
    zle fzf-tab-complete
    zle copy-region-as-kill
}
zle -N fix-fzf-tab
bindkey "^I" fix-fzf-tab

bindkey -v

KEYTIMEOUT=25

# Updates editor information when the keymap changes.
function zle-keymap-select()
{
    # change cursor style in vi-mode
    case $KEYMAP in
        vicmd)      print -n -- "\e[1 q" ;;
        viins|main) print -n -- "\e[5 q" ;;
        vivis)      print -n -- "\e[1 q" ;;
    esac

    zle reset-prompt
    zle -R
}

# Start every prompt in insert mode
function zle-line-init ()
{
    zle -K viins
}

function clip-paste ()
{
    CUTBUFFER=$(xsel -o -b </dev/null)
    zle yank
    # Needed in order for the highlighting rules to apply
    zle copy-region-as-kill
}

function clip-copy ()
{
    zle copy-region-as-kill
    zle deactivate-region
    print -rn $CUTBUFFER | xsel -i -b
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N clip-paste
zle -N clip-copy

bindkey -M  vicmd "U"  redo
bindkey -M  vicmd "k"  up-history
bindkey -M  vicmd "j"  down-history
bindkey -M  vicmd "L"  forward-word
bindkey -M  vicmd "H"  backward-word
bindkey -sM vicmd ":"  ""
bindkey -sM vicmd "/"  ""
bindkey -M  vicmd "y"  clip-copy
bindkey -M  vicmd "^y" clip-copy
bindkey -M  vicmd "p"  clip-paste
bindkey -M  vicmd "^p" clip-paste

bindkey -M viins "jj"   vi-cmd-mode
bindkey -M viins "^?"   backward-delete-char
bindkey -M viins "^[^?" backward-kill-word
bindkey -M viins "^l"   autosuggest-accept
bindkey -M viins "^y"   clip-copy
bindkey -M viins "^p"   clip-paste

bindkey -M visual "^I" select-in-word

# Needed in order for the highlighting rules to apply
function fix-autopair-insert ()
{
    autopair-insert
    zle copy-region-as-kill
}

zle -N fix-autopair-insert

for p in ${(@k)AUTOPAIR_PAIRS}; do
    bindkey "$p" fix-autopair-insert
    bindkey -M isearch "$p" self-insert
done

alias stcpu="stress -c 8"
alias stmem="stress -vm 2 --vm-bytes"

alias ls="exa -lah --color=always --group-directories-first"
alias cat="bat"
alias vim="nvim"
alias rm="rm -r"
alias cp="cp -r"
alias pin="sudo pin"

alias src="source ~/.config/zsh/.zshrc"
alias mkcd="foo(){ mkdir -p \"$1\"; cd \"$1\" }; foo "
alias c="clear"
alias env="xdotool keydown Shift; printenv | fzf; xdotool keyup Shift"
alias als="alias | fzf"
alias upgrade="yay -Syu"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../../../"
alias .....="cd ../../../../"
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Colorize grep output
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

alias -g H="| head"
alias -g T="| tail"
alias -g G="| grep"
alias -g L="| less"
alias -g M="| most"
alias -g C='| wc -l'
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"

# git
alias gac="git add . && git commit -a -m "

# Resetting the terminal with escape sequences
function reset_broken_terminal()
{
    printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8'
}
autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd reset_broken_terminal

source /usr/share/doc/pkgfile/command-not-found.zsh

# lf
function lfcd()
{
    tmp="$(mktemp)"
    lfrun -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
alias lf="lfcd"

# Run neofetch
[[ $run_neofetch ]] && echo "" && neofetch
