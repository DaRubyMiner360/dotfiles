#!/bin/bash

previous_monitors="[]"

while true; do
  current_monitors=$(hyprctl monitors -j | jq -c '[.[].id]')
  removed_monitors=$(jq -c -n "$previous_monitors - $current_monitors")
  if [[ "$previous_monitors" == *"error"* ]] || [[ "$current_monitors" == *"error"* ]] || [[ "$removed_monitors" == *"error"* ]] || [[ "$removed_monitors" != *"["* ]] || [[ "$removed_monitors" != *"]"* ]]; then
    echo "ERROR:"
    echo "Previous Monitors: $previous_monitors"
    echo "Current Monitors: $current_monitors"
    echo "Removed Monitors: $removed_monitors"
    echo ""

    sleep 1
    continue
  fi
  if [ "$removed_monitors" != "[]" ]; then
    echo "Previous Monitors: $previous_monitors"
    echo "Current Monitors: $current_monitors"
    echo "Removed Monitors: $removed_monitors"
    echo ""
  fi
  previous_monitors=$current_monitors

  if [ "$removed_monitors" != "[]" ]; then
    ~/.config/hypr/scripts/awesome_workspaces.sh refresh_mapping

    # for id in $(echo $removed_monitors | jq -r '.[]'); do
    # done

    if pgrep "swww" > /dev/null && [ -f ~/.cache/current_wallpaper.png ]; then
      ~/.config/hypr/scripts/set_wallpaper ~/.cache/current_wallpaper.png & disown
    else
      ~/.config/hypr/scripts/set_wallpaper & disown
    fi
  fi

  sleep 1
done
