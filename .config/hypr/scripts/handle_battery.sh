#!/bin/bash

while true; do
  info=$(~/.config/eww/scripts/get_first_available_battery.sh)
  stat=$(echo $info | jq -r '.status')
  perc=$(echo $info | jq '.capacity')
  text=$(echo $info | jq -r '.text')

  if [[ $text == "No Batteries Found" ]]; then
    sleep 1
    continue
  fi

  if [[ $stat == "Discharging" ]] && cat /proc/acpi/button/lid/LID0/state | grep -q "closed"; then
    systemctl suspend
  fi
  sleep 1
done

