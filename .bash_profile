export PATH=$HOME/.config/rofi/scripts:$HOME/.config/lf/scripts:$HOME/.local/bin:$PATH
export ZDOTDIR="$HOME/.config/zsh"
export TPATH="$HOME/.local/share/my-trash"

export SHELL="/bin/bash"
export EDITOR="/bin/nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Clean-up
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export HISTFILE="$XDG_CACHE_HOME/history"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"
export CALCHISTFILE="$XDG_CACHE_HOME/calc_history"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"

if [ ! -e $WGETRC ]
then
    echo hsts-file \= "$XDG_CACHE_HOME"/wget-hsts > "$XDG_CONFIG_HOME/wgetrc"
fi

[[ ! -d $TPATH ]] && mkdir -p $TPATH
[[ -f /usr/bin/udiskie ]] && udiskie &

setxkbmap -layout 'us,ru' -option 'grp:caps_toggle'
xset r rate 300 24
syndaemon -t -i 1 -d

lines="$(cat $TPATH/.record)"
IFS='
'
for line in $lines
do
    date=$(echo "$line" | awk 'BEGIN{FS="\t"} {print $1}' | tr -d '\n')
    prev=$(date --date="$date" +"%j")
    today=$(date +%j)
    number_of_days=$(( ($today - $prev) ))

    if [ $number_of_days -gt 8 ]
    then
        file=$(echo "$line" | awk 'BEGIN{FS="\t"} {print $3}' | tr -d '\n')
        rm -rf $file
        file=$(echo $file | sed 's|\/|\\\/|g')
        sed -i "/$file/d" $TPATH/.record
    fi
done
