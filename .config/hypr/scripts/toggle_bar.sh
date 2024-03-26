#!/bin/bash

opened=false
if [[ "$(eww active-windows)" =~ "bar0:" ]] || [[ "$(eww active-windows)" =~ "notch0:" ]]; then
  opened=true
fi

for id in $(hyprctl monitors -j | jq -r '.[].id'); do
  if [ $opened = true ]; then
    eww close bar$id || eww close notch$id
  else
    if [ $(eww get autohide) = true ]; then
      eww open notch$id
    else
      eww open bar$id
    fi
  fi
done
