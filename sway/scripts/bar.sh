#!/bin/bash

set -euo pipefail

BAR_CONFIG="$HOME/.config/sway/bar"

while read -r _ name value; do
    printf -v "${name#\$}" '%s' "$value"
done < <(
    awk '$1 == "set" && $2 ~ /^\$[A-Z_]+$/ && $3 ~ /^#[A-Fa-f0-9]{6}$/ {
        print $1, $2, $3
    }' "$BAR_CONFIG"
)

segment() {
    printf '<span foreground="%s">%s</span>' "$1" "$2"
}

separator() {
    segment "$MUTED" ' 󰇙 '
}

network() {
    local type signal name

    type=$(nmcli -t -f TYPE,STATE device |
        awk -F: '$2 == "connected" { print $1; exit }')

    case "$type" in
        wifi)
            name=$(nmcli -t -f ACTIVE,SSID device wifi |
                awk -F: '$1 == "yes" { print $2; exit }')

            signal=$(nmcli -t -f ACTIVE,SIGNAL dev wifi |
                awk -F: '$1 == "yes" { print $2; exit }')

            if (( signal >= 80 )); then
                segment "$SUCCESS" "<b>󰤨</b>  $name"
            elif (( signal >= 60 )); then
                segment "$INFO" "<b>󰤥</b>  $name"
            elif (( signal >= 40 )); then
                segment "$WARNING" "<b>󰤢</b>  $name"
            else
                segment "$DANGER" "<b>󰤟</b>  $name"
            fi
            ;;

        ethernet)
            segment "$SUCCESS" '<b>󰈀</b>  Ethernet'
            ;;

        *)
            segment "$DANGER" '<b>󰤭</b>  Offline'
            ;;
    esac
}

battery() {
    local capacity status

    capacity=$(< /sys/class/power_supply/BAT*/capacity)
    status=$(< /sys/class/power_supply/BAT*/status)

    if [[ $status == Charging ]]; then
        segment "$INFO" "<b>󰂄</b>  $capacity%"
    elif (( capacity >= 60 )); then
        segment "$SUCCESS" "<b>󰁹</b>  $capacity%"
    elif (( capacity >= 30 )); then
        segment "$WARNING" "<b>󰁾</b>  $capacity%"
    else
        segment "$DANGER" "<b>󰁺</b>  $capacity%"
    fi
}

volume() {
    local output volume

    output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

    if [[ $output == *MUTED* ]]; then
        segment "$MUTED" '<b>󰝟</b>  Muted'
        return
    fi

    volume=$(awk '{ print int($2 * 100) }' <<< "$output")

    if (( volume >= 80 )); then
        segment "$DANGER" "<b>󰕾</b>  $volume%"
    elif (( volume >= 50 )); then
        segment "$WARNING" "<b>󰖀</b>  $volume%"
    else
        segment "$SUCCESS" "<b>󰕿</b>  $volume%"
    fi
}

clock() {
    segment "$INFO" "<b>󰃭</b>  $(date '+%a, %b %d')"
    separator
    segment "$ACCENT" "<b>󰥔</b>  $(date '+%I:%M %p')"
}

while :; do
    bar=$(
        network
        separator
        battery
        separator
        volume
        separator
        clock
    )

    printf '%s' "$bar"
    sleep 0.25
done
