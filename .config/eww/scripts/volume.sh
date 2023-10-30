#!/bin/bash

# @requires: wpctl

percentage () {
  local val=$(echo $1 | tr '%' ' ' | awk '{print $1}')
  local icon1=$2
  local icon2=$3
  local icon3=$4
  local icon4=$5
  if [ "$val" -le 15 ]; then
    echo $icon1
  elif [ "$val" -le 30 ]; then
    echo $icon2
  elif [ "$val" -le 60 ]; then
    echo $icon3
  else
    echo $icon4
  fi
}

is_muted () {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q " \[MUTED\]" && echo yes || echo no
}

get_percentage() {
	volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/.*Volume: //' | sed 's/ \[MUTED\].*//' | sed 's/\.//g' | sed 's/^0*//')
  if [[ "$volume" -eq "" ]]; then
    volume=0
  fi
  echo "${volume}%"
}

get_icon () {
  local muted=$(is_muted)
  local vol=$(get_percentage)
  if [[ $muted == 'yes' ]]; then
    echo "婢"
  else
    echo $(percentage "$vol" "" "" "墳" "")
  fi
}

get_class () {
  local muted=$(is_muted)
  local vol=$(get_percentage)
  if [[ $muted == 'yes' ]]; then
    echo "red"
  else
    echo $(percentage "$vol" "red" "magenta" "yellow" "blue")
  fi
}

get_vol () {
  local percent=$(get_percentage)
  echo $percent | tr -d '%'
}

if [[ $1 == "icon" ]]; then
  get_icon
fi

if [[ $1 == "class" ]]; then
  get_class
fi

if [[ $1 == "percentage" ]]; then
  get_percentage
fi

if [[ $1 == "vol" ]]; then
  get_vol
fi

if [[ $1 == "muted" ]]; then
  is_muted
fi

if [[ $1 == "toggle-muted" ]]; then
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  ~/.config/hypr/scripts/volume --toggle
fi

if [[ $1 == "set" ]]; then
  val=$(echo $2 | tr '.' ' ' | awk '{print $1}')
  if test $val -gt 100; then
    val=100
  fi
  wpctl set-volume @DEFAULT_AUDIO_SINK@ $val%
  ~/.config/hypr/scripts/volume --change
fi

