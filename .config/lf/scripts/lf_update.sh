#!/bin/sh

disk_info=$(lf_disk "$1")

lf -remote "send $2 set promptfmt \"\
 \033[38;5;8m[\033[0m\
\033[34;1m%u\033[0m\
\033[38;5;8m]─[\033[0m\
\033[38;5;11m\033[3;1m%h\033[0m\
\033[38;5;8m]─[\033[0m\
$disk_info\
\033[38;5;8m]─[\033[0m\
\033[32;1m%d\033[0m\
\033[3;1m%f\033[0m\
\033[38;5;8m]\033[0m\""

lf -remote "send recol"
