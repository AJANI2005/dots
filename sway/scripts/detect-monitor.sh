#!/bin/bash

declare -A state

for status in /sys/class/drm/*/status; do
    [[ -f "$status" ]] || continue
    state["$status"]="$(cat "$status")"
done

udevadm monitor --udev --subsystem-match=drm |
while IFS= read -r event; do
    [[ "$event" == *"change"* ]] || continue

    sleep 0.1

    for status in /sys/class/drm/*/status; do
        [[ -f "$status" ]] || continue

        current=$(cat "$status")
        previous="${state[$status]}"

        [[ "$current" == "$previous" ]] && continue

        state["$status"]="$current"

        name=$(basename "$(dirname "$status")")

        case "$current" in
            connected)
                notify-send "Monitor connected" "$name"
                ;;
            disconnected)
                notify-send "Monitor disconnected" "$name"
                ;;
        esac
    done
done
