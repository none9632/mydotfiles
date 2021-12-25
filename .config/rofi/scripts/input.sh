#!/bin/sh

rofi_command="rofi -dmenu\
                   -i\
                   -fixed-num-lines\
                   -monitor -2\
                   -p \" $1 \"\
                   -theme $HOME/.config/rofi/themes/other/input.rasi\
                   -kb-secondary-paste    Control+p,Control+k,Up\
                   -kb-clear-line         Control+d,Down\
                   -kb-move-front         Control+i\
                   -kb-move-end           Control+a\
                   -kb-move-char-back     Control+h,Left\
                   -kb-move-char-forward  Control+l,Right\
                   -kb-row-up             \"\"\
                   -kb-row-down           \"\""

echo -n "$(eval $rofi_command)"
