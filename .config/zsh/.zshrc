autoload -Uz add-zsh-hook

export ZIT_MODULES_PATH="${ZDOTDIR}/plugins/"

if [[ ! -d "${ZIT_MODULES_PATH}/zit" ]]; then
    git clone "https://github.com/none9632/zit.git" "${ZIT_MODULES_PATH}/zit"
fi

source "${ZIT_MODULES_PATH}/zit/zit.zsh"

zit-il "zsh-users/zsh-autosuggestions"
zit-il "zsh-users/zsh-completions"
zit-il "zdharma-continuum/fast-syntax-highlighting"
# zit-il "zsh-users/zsh-syntax-highlighting"
zit-il "Aloxaf/fzf-tab"
zit-il "hlissner/zsh-autopair"

function fix-autopair-insert ()
{
    autopair-insert
    xdotool key '0xff89'
}

zle -N fix-autopair-insert

for p in ${(@k)AUTOPAIR_PAIRS}; do
    bindkey "$p" fix-autopair-insert
    bindkey -M isearch "$p" self-insert
done

autoload -Uz compinit && compinit

setopt COMPLETE_ALIASES
# _comp_options+=(globdots)

zmodload zsh/complist

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.cache/zsh/history

# Ignoring repetitive lines in the history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
# setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

autoload -U promptinit && promptinit
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
ZSH_HIGHLIGHT_REGEXP+=('\bhttp://\S*\b' fg=#51afef,underline)
ZSH_HIGHLIGHT_REGEXP+=('\bhttps://\S*\b' fg=#51afef,underline)

ZSH_HIGHLIGHT_STYLES[arg0]='fg=#c792ea'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#e7c07b'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#e7c07b'
ZSH_HIGHLIGHT_STYLES[path]='fg=#98be65'

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -v

KEYTIMEOUT=25

# Updates editor information when the keymap changes.
function zle-keymap-select()
{
    # change cursor style in vi-mode
    case $KEYMAP in
        vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;
        viins|main) print -n -- "\E]50;CursorShape=1\C-G";;
        vivis)      print -n -- "\E]50;CursorShape=0\C-G";;
    esac

    zle reset-prompt
    zle -R
}

# Start every prompt in insert mode
function zle-line-init() { zle -K viins }

function exit_zsh() { exit }

zle -N zle-line-init
zle -N zle-keymap-select
zle -N exit_zsh

bindkey -M  vicmd "U"  redo
bindkey -M  vicmd "zz" kill-whole-line
bindkey -M  vicmd "k"  up-history
bindkey -M  vicmd "j"  down-history
bindkey -M  vicmd "L"  forward-word
bindkey -M  vicmd "H"  backward-word
bindkey -sM vicmd ":"  ""
bindkey -sM vicmd "/"  ""
bindkey -M  vicmd "q"  exit_zsh

bindkey -M  viins "jj" vi-cmd-mode
bindkey -M  viins "^?" backward-delete-char
bindkey -sM viins "^l" "jjla"

copy-to-xclip()
{
    [[ "$REGION_ACTIVE" -ne 0 ]] && zle copy-region-as-kill
    print -rn -- $CUTBUFFER | xclip -selection clipboard -i
}

normal-paste-xclip() {
    killring=("$CUTBUFFER" "${(@)killring[1,-2]}")
    CUTBUFFER=$(xclip -selection clipboard -o)
    zle yank
    xdotool key 'h'
    xdotool key 'l'
}

insert-paste-xclip() {
    killring=("$CUTBUFFER" "${(@)killring[1,-2]}")
    CUTBUFFER=$(xclip -selection clipboard -o)
    zle yank
    xdotool key 'KP_Tab'
}

zle -N copy-to-xclip
zle -N normal-paste-xclip
zle -N insert-paste-xclip

# bindkey -M vicmd "y" copy-to-xclip
bindkey -M vicmd "p"  normal-paste-xclip
bindkey -M viins "^p" insert-paste-xclip

function reset_broken_terminal()
{
    printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8'
}

add-zsh-hook -Uz precmd reset_broken_terminal

alias stcpu="stress -c 8"
alias stmem="stress -vm 2 --vm-bytes"

alias pacman="sudo pacman"
alias pacsyu="sudo pacman -Syu"
alias yaysyu="yay -Syu"

alias ls="exa -la --color=always --group-directories-first"
alias cat="bat"
alias rm="rm -r"
alias cp="cp -r"

# lf
. $HOME/.config/lf/.lfrc

# Persistent rehash
zstyle ':completion:*' rehash true

# Unpacking the archive
ex ()
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
pk ()
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

enable-fzf-tab

cd ~

# Run neofetch
[[ -f /usr/bin/neofetch ]] && echo "" && neofetch
