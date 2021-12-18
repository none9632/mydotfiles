#!/usr/bin/env bash

rofi_command="rofi -kb-move-char-back Left,h\
                   -kb-move-char-forward Right,l\
                   -theme $HOME/.config/rofi/menu_themes/powermenu.rasi"

uptime=$(uptime -p | sed -e 's/up //g')

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

xdotool key Mode_switch

# Variable passed to rofi
options="$lock\n$reboot\n$shutdown\n$suspend\n$logout"
chosen="$(echo -e "$options" | $rofi_command -p " 祥  $uptime " -dmenu -selected-row 2)"
case $chosen in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $lock)
        if [[ -f /usr/bin/i3lock ]]; then
            i3lock
        elif [[ -f /usr/bin/betterlockscreen ]]; then
            betterlockscreen -l
        fi
        ;;
    $suspend)
        mpc -q pause
        amixer set Master mute
        systemctl suspend
        ;;
    $logout)
        if [[ "$DESKTOP_SESSION" == "Openbox" ]]; then
            openbox --exit
        elif [[ "$DESKTOP_SESSION" == "bspwm" ]]; then
            bspc quit
        elif [[ "$DESKTOP_SESSION" == "i3" ]]; then
            i3-msg exit
        fi
        ;;
esac
