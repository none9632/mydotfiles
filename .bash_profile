export PATH=$HOME/.config/rofi/bin:$HOME/.config/lf/bin:$HOME/.local/bin:$PATH
# export ZDOTDIR="$HOME/.config/zsh"
# export POLYBAR_LAUNCH="$HOME/Desktop/mydotfiles/.config/polybar/launch.sh"

# export SHELL="/bin/zsh"
export SHELL="/bin/bash"
export EDITOR="/bin/nvim"

[[ -f /usr/bin/udiskie ]] && udiskie &

xset r rate 300 24
syndaemon -t -i 1 -d
trash-empty 7 &

[[ -f ~/.bashrc ]] && . ~/.bashrc
