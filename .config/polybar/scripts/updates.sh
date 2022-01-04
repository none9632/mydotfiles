#!/bin/sh

NOTIFY_ICON=/usr/share/icons/Papirus/32x32/apps/system-software-update.svg

get_total_updates() {
    sudo yay -Syy 2>~/.cache/updates/updates.log
    updates=$(yay -Qu 2>/dev/null | wc -l);
}

while true; do
    echo "  0"
    sleep 1
    get_total_updates

    # notify user of updates
    if hash notify-send &>/dev/null && [ $updates -gt 0 ]
    then
        notify-send -u normal -i $NOTIFY_ICON \
                    "You should update soon" "$updates New packages"
    fi

    # when there are updates available
    # every 100 seconds another check for updates is done
    while (( $updates > 0 )); do
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
    while (( $updates == 0 )); do
        echo "  0"
        sleep 600
        get_total_updates
    done
done
