#!/bin/bash

monitor=$(hyprctl monitors -j | jq '.[] | select(.focused) | .id')

eww open $1$monitor --toggle
if eww get $1_open >/dev/null 2>/dev/null; then
  if [ $(eww get $1_open) -eq -1 ]; then
    eww update $1_open=$monitor
  else
    eww update $1_open=-1
  fi
fi
