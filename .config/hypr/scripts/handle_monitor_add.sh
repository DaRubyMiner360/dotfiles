#!/bin/bash

previous_monitors="[]"

while true; do
  current_monitors=$(hyprctl monitors -j | jq -c '[.[].id]')
  new_monitors=$(jq -c -n "$current_monitors - $previous_monitors")

  if [ "$new_monitors" != "[]" ]; then
    previous_monitors=$current_monitors

    for id in $(echo $new_monitors | jq -r '.[]'); do
      if [ $(eww get autohide) = true ]; then
        eww open notch$id
      else
        eww open bar$id
      fi
    done
    # Just in case the bar is acting up on the new monitor, reload eww
    eww reload

    ~/.config/hypr/scripts/set_wallpaper
  fi

  sleep 1
done
