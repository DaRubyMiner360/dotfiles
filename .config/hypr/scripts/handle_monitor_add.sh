#!/bin/bash

previous_monitors="[]"

while true; do
  current_monitors=$(hyprctl monitors -j | jq -c '[.[].id]')
  added_monitors=$(jq -c -n "$current_monitors - $previous_monitors")
  if [[ "$previous_monitors" == *"error"* ]] || [[ "$current_monitors" == *"error"* ]] || [[ "$added_monitors" == *"error"* ]] || [[ "$added_monitors" != *"["* ]] || [[ "$added_monitors" != *"]"* ]]; then
    echo "ERROR:"
    echo "Previous Monitors: $previous_monitors"
    echo "Current Monitors: $current_monitors"
    echo "Added Monitors: $added_monitors"
    echo ""
    added_monitors="[]"
  fi
  if [ "$added_monitors" != "[]" ]; then
    echo "Previous Monitors: $previous_monitors"
    echo "Current Monitors: $current_monitors"
    echo "Added Monitors: $added_monitors"
    echo ""
  fi
  previous_monitors=$current_monitors

  if [ "$added_monitors" != "[]" ]; then
    for id in $(echo $added_monitors | jq -r '.[]'); do
      if [ "$(eww get autohide)" = true ]; then
        eww open notch$id
      else
        eww open bar$id
      fi
    done
    # Just in case the bar is acting up on the new monitor, reload eww
    eww reload

    if pgrep "swww" > /dev/null && [ -f ~/.cache/current_wallpaper.jpg ]; then
      ~/.config/hypr/scripts/set_wallpaper ~/.cache/current_wallpaper.jpg & disown
    else
      ~/.config/hypr/scripts/set_wallpaper & disown
    fi

    ~/.config/hypr/scripts/awesome_workspaces.sh refresh_mapping
  fi

  sleep 1
done
