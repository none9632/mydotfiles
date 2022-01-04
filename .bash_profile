export PATH=$HOME/.config/rofi/scripts:$HOME/.config/lf/scripts:$HOME/.local/bin:$PATH
export ZDOTDIR="$HOME/.config/zsh"
export POLYBAR_LAUNCH="$HOME/Desktop/mydotfiles/.config/polybar/launch.sh"

export SHELL="/bin/bash"
export EDITOR="/bin/nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

[[ -f /usr/bin/udiskie ]] && udiskie &

xset r rate 300 24
syndaemon -t -i 1 -d
trash-empty 7 &
