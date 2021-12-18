#!/bin/sh

xdotool key Mode_switch

rofi -show drun\
     -theme $HOME/.config/rofi/menu_themes/appslauncher.rasi\
     -scroll-method 1\
