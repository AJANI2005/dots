#!/bin/sh

if pgrep -x swayidle >/dev/null; then
    pkill -x swayidle
    notify-send "Idle" "Disabled"
else
    ~/.config/sway/scripts/idle.sh &
    notify-send "Idle" "Enabled"
fi
