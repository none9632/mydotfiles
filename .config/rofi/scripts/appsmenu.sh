#!/usr/bin/env bash

rofi_command="rofi -kb-move-char-back Left,h\
                   -kb-move-char-forward Right,l\
                   -kb-row-first H\
                   -kb-row-last L\
                   -theme $HOME/.config/rofi/themes/menu/appsmenu.rasi"

# Links
terminal=""
files=""
editor=""
browser=""
settings=""

if [[ -f /usr/bin/alacritty ]]; then
    term=alacritty
else
    error_msg "No suitable terminal found!"
fi

# Variable passed to rofi
options="$files\n$editor\n$terminal\n$browser\n$settings"

xdotool key Mode_switch

chosen="$(echo -e "$options" | $rofi_command -p " Most Used " -dmenu -selected-row 2)"
case $chosen in
    $terminal)
        $term &
        ;;
    $files)
        if [[ -f /usr/bin/lf ]]; then
            . $HOME/.config/lf/.lfrc
            $term -e lf &
        else
            error_msg "No suitable file manager found!"
        fi
        ;;
    $editor)
        if [[ -f /usr/bin/emacs ]]; then
            emacs &
        else
            error_msg "No suitable text editor found!"
        fi
        ;;
    $browser)
        if [[ -f /usr/bin/librewolf ]]; then
            librewolf &
        else
            error_msg "No suitable web browser found!"
        fi
        ;;
    $settings)
        if [[ -f /usr/bin/xfce4-settings-manager ]]; then
            xfce4-settings-manager &
        else
            error_msg "No suitable settings manager found!"
        fi
        ;;
esac