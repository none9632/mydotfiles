#!/bin/bash

rofi_command="rofi -kb-move-char-back Left,h\
                   -kb-move-char-forward Right,l\
                   -theme $HOME/.config/rofi/menu_themes/screenshot.rasi"

scr_dir="$HOME/Pictures/screenshots"
mkdir -p "${scr_dir}"

getStamp()
{
    date '+%Y%m%d-%H%M%S'
}

if [[ ! -f /usr/bin/scrot ]] || [[ ! -f /usr/bin/flameshot ]]
then
    [[ -f /usr/bin/scrot ]] && error_msg "Please install 'scrot'"
    [[ -f /usr/bin/flameshot ]] && error_msg "Please install 'flameshot'"
    exit 0
fi

# Options
screen=""
window=""
area=""
options="$window\n$screen\n$area"

xdotool key Mode_switch

chosen="$(echo -e "$options" | $rofi_command -p ' scrot/flameshot ' -dmenu -selected-row 1)"
sleep 0.35
case $chosen in
    $screen)
        scr_name=full-$(getStamp).png
        scrot ${scr_dir}/${scr_name}
        ;;
    $window)
        scr_name=window-$(getStamp).png
        scrot -u ${scr_dir}/${scr_name}
        ;;
    $area)
        window_focus=$(xdotool getwindowfocus)
        flameshot gui --path "$scr_dir" -r > /dev/null
        scr_path=$(find "$scr_dir" -type f -newermt `date --date='1 second ago' +%Y-%m-%dT%H:%M:%S` | head -n 1)
        scr_name=$(basename $scr_path)
        xdotool windowfocus $window_focus
        ;;
    *)
        exit 0
        ;;
esac

NOTIFY_ICON=/usr/share/icons/Adwaita/32x32/apps/system-users-symbolic.symbolic.png
# NOTIFY_ICON=${scr_dir}/${scr_file}
if [ -n "$scr_name" ]
then
    notify-send -u normal -i $NOTIFY_ICON \
                "Screenshot" "Screenshot save as $scr_name"
fi
