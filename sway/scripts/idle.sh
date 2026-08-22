#!/bin/sh

swayidle -w \
    timeout 150 'brightnessctl -s && brightnessctl set 50%' \
        resume 'brightnessctl -r' \
    timeout 300 'swaylock -f -C ~/.config/swaylock/config' \
    timeout 600 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
    before-sleep 'swaylock -f -C ~/.config/swaylock/config'
