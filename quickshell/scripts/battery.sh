#!/bin/sh

for dev in /sys/class/power_supply/BAT*; do
    if [ -d "$dev" ]; then
        cat "$dev/capacity"
        cat "$dev/status"
        exit 0
    fi
done

if command -v upower >/dev/null 2>&1; then
    upower -i "$(upower -e | grep 'battery' | head -n1)" | grep -E 'percentage|state' | awk '{print $2}'
else
    echo 'No battery'
fi
