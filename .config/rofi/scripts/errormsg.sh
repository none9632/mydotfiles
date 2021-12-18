#!/usr/bin/env bash

options=""
rofi_command="rofi -monitor -2 -theme $HOME/.config/rofi/styles/error_msg.rasi"
$(echo -e "$options" | $rofi_command -p " $1 " -dmenu)
