#!/bin/sh

bat=/sys/class/power_supply/BAT0
CRIT=${1:-15}

FILE=~/.config/eww/scripts/notified

stat=$(cat $bat/status)
perc=$(cat $bat/capacity)

if [[ $stat == "Discharging" ]] && cat /proc/acpi/button/lid/LID0/state | grep -q "closed"; then
  systemctl suspend
fi

if [[ $perc -le $CRIT ]] && [[ $stat == "Discharging" ]]; then
  if [[ ! -f "$FILE" ]]; then
    notify-send --urgency=critical --icon=dialog-warning "Battery Low" "Current charge: $perc%"
    touch $FILE
  fi
elif [[ -f "$FILE" ]]; then
  rm $FILE
fi

