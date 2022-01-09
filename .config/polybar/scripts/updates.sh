#!/bin/sh

notify_icon=/usr/share/icons/Papirus/32x32/apps/system-software-update.svg
cache_dir=$HOME/.cache/updates
yay_log_file=$cache_dir/updates.log

get_total_updates ()
{
    # sudo yay -Syy 2>~/.cache/updates/updates.log
    update
    updates=$(yay -Qu 2>/dev/null | wc -l);
}

while true
do
    echo "  0"
    sleep 1
    get_total_updates

    # notify user of updates
    if hash notify-send &>/dev/null && [ $updates -gt 0 ]
    then
        notify-send -u normal -i $notify_icon \
                    "You should update soon" "$updates New packages"
    fi
    if [ $(cat $log_file | wc -l) -gt 0 ]
    then
        notify-send -u normal -i $notify_icon \
                    "Error in updates script" "Something wrong"
    fi


    # when there are updates available
    # every 100 seconds another check for updates is done
    while (( $updates > 0 ))
    do
        if (( $updates > 99 )); then
            echo "$updates"
        elif (( $updates > 9 )); then
            echo " $updates"
        else
            echo "  $updates"
        fi
        sleep 600
        get_total_updates
    done

    # when no updates are available, use a longer loop, this saves on CPU
    # and network uptime, only checking once every 10 min for new updates
    while (( $updates == 0 ))
    do
        echo "  0"
        sleep 600
        get_total_updates
    done
done
