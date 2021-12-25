#!/bin/sh

disk=$(df --output=source "$1" | tail -n 1 | grep /dev/)

if [ "$disk" = "" ]
then
    IFS=" " read -ra disk_info <<< "$(df -P -BK / | tail -n 1)"
else
    IFS=" " read -ra disk_info <<< "$(df -P -BK ${disk} | tail -n 1)"
fi

size=$(echo "${disk_info[1]}" | sed 's|[^[:digit:]]\+||g')
used=$(echo "${disk_info[2]}" | sed 's|[^[:digit:]]\+||g')

size_m=$(printf '%.1f' "$(echo "scale=1; $size/1024" | bc)")
used_m=$(printf '%.1f' "$(echo "scale=1; $used/1024" | bc)")

size_g=$(printf '%.1f' "$(echo "scale=1; x=$size_m; if (x>1024) x=x/1024; x" | bc)")
used_g=$(printf '%.1f' "$(echo "scale=1; x=$used_m; if (x>1024) x=x/1024; x" | bc)")

if [ "$size_m" = "$size_g" ]
then
    size=$(echo "${size_m}M")
else
    size=$(echo "${size_g}G")
fi

if [ "$used_m" = "$used_g" ]
then
    used=$(echo "${used_m}M")
else
    used=$(echo "${used_g}G")
fi

echo "\
\033[35;5;5m\033[3;1m${used}\
\033[38;5;8m/\
\033[35;5;5m\033[3;1m${size}\033[0m"
