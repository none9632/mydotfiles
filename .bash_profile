export PATH=$HOME/.config/rofi/scripts:$HOME/.config/lf/scripts:$HOME/.local/bin:$PATH
export ZDOTDIR="$HOME/.config/zsh"
export TPATH="$HOME/.local/share/my-trash"

export SHELL="/bin/bash"
export EDITOR="/bin/nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

[[ ! -d $TPATH ]] && mkdir -p $TPATH
[[ -f /usr/bin/udiskie ]] && udiskie &

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
        rip --graveyard $TPATH -u $file
    fi
done
