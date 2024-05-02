#!/bin/bash

if cat /proc/acpi/button/lid/LID0/state | grep -q "open"; then
  hyprctl keyword monitor "eDP-1, preferred, auto, 1"
else
  if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
      hyprctl keyword monitor "eDP-1, disable"
  fi

  battery_status=$(~/.config/eww/scripts/get_first_available_battery.sh | jq -r '.status')
  if [[ $battery_status == "Discharging" ]]; then
    systemctl suspend
  fi
fi
