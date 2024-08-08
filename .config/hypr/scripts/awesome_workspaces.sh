#!/bin/bash

WORKSPACES_PER_MONITOR=100
KEEP_FOCUSED=true

DEBUG=true

monitor_workspace_map=()

write_monitor_workspace_map() {
  rm -f $HOME/.config/hypr/scripts/.monitor_workspace_map
  for key in "${!monitor_workspace_map[@]}"; do
    echo "$key=${monitor_workspace_map[$key]}" >> $HOME/.config/hypr/scripts/.monitor_workspace_map
  done
}

load_monitor_workspace_map() {
  monitor_workspace_map=()
  if [ -f $HOME/.config/hypr/scripts/.monitor_workspace_map ]; then
    readarray -t lines < "$HOME/.config/hypr/scripts/.monitor_workspace_map"
    for line in "${lines[@]}"; do
      key=${line%%=*}
      value_string=${line#*=}
      monitor_workspace_map[$key]=$value_string
    done
  fi
}
load_monitor_workspace_map

add_to_monitor_workspace_map() {
  key=$1
  value=$2

  if [[ ! ${monitor_workspace_map[$key]+_} ]]; then
    monitor_workspace_map[$key]="$value"
  else
    monitor_workspace_map[$key]+=" $value"
  fi
  write_monitor_workspace_map
}

map_workspaces_to_monitors() {
  monitor_workspace_map=()

  originally_focused_monitor_id=$(hyprctl activeworkspace -j | jq '.monitorID')
  originally_focused_workspace_id=$(hyprctl activeworkspace -j | jq '.id')

  workspace_index=1
  for row in $(hyprctl monitors -j | jq -r '.[] | @base64'); do
    monitor=$(echo $row | base64 --decode)
    log_message="[awesome-workspaces] Mapping workspaces $workspace_index-$((workspace_index + WORKSPACES_PER_MONITOR - 1)) to monitor $(echo $monitor | jq -r '.name')"
    hyprctl notify -1 5000 "rgb(61afef)" $log_message

    for i in $(seq $workspace_index $((workspace_index + WORKSPACES_PER_MONITOR - 1))); do
      workspace_name="$i"
      monitor_id=$(echo $monitor | jq -r '.id')
      add_to_monitor_workspace_map $monitor_id $workspace_name
      monitor_name=$(echo $monitor | jq -r '.name')
      hyprctl keyword workspace $workspace_name,$monitor_name
      workspace=$(hyprctl workspaces -j | jq ".[] | select(.name==\"$workspace_name\")")
      workspace_id=$(echo $workspace | jq -r '.id')

      if [ ! -z "$workspace" ]; then
        hyprctl dispatch moveworkspacetomonitor $workspace_id $monitor_id
      fi
    done

    if [ $KEEP_FOCUSED != true ] || [ $(echo $monitor | jq -r '.activeWorkspace.id') -lt $((workspace_index + 1)) ] || [ $(echo $monitor | jq -r '.activeWorkspace.id') -gt $((workspace_index + 1 + WORKSPACES_PER_MONITOR)) ]; then      hyprctl dispatch focusmonitor $monitor_id
      hyprctl dispatch workspace $workspace_index
    fi
    workspace_index=$((workspace_index + WORKSPACES_PER_MONITOR))
  done
  write_monitor_workspace_map

  hyprctl dispatch focusmonitor $originally_focused_monitor_id
  hyprctl dispatch workspace $originally_focused_workspace_id
}

get_workspace_from_monitor() {
  monitor_id=$1
  workspace=$2

  monitor=$(hyprctl monitors -j | jq ".[] | select(.id==$monitor_id)")

  if [[ $workspace != "0" ]] && [[ $workspace =~ ^[0-9]+$ ]]; then
    workspace_index=$((workspace - 1))
  
    read -r -a val <<< "${monitor_workspace_map[$monitor_id]}"
    if [ $workspace_index -ge ${#val[@]} ]; then
      echo $workspace
    else
      echo ${val[$workspace_index]}
    fi
  else
    if [ $DEBUG == true ]; then
      hyprctl notify 0 5000 "rgb(61afef)" "[awesome-workspaces] WARNING: Invalid workspace index: $workspace" >/dev/null
    fi
    echo $workspace
  fi
}

split_workspace() {
  workspace=$1

  monitor_id=$(hyprctl activeworkspace -j | jq '.monitorID')
  monitor=$(hyprctl monitors -j | jq ".[] | select(.id==$monitor_id)")

  hyprctl dispatch workspace $(get_workspace_from_monitor $monitor_id $workspace)
}

split_move_to_workspace() {
  workspace=$1

  monitor_id=$(hyprctl activeworkspace -j | jq '.monitorID')
  monitor=$(hyprctl monitors -j | jq ".[] | select(.id==$monitor_id)")

  hyprctl dispatch movetoworkspace $(get_workspace_from_monitor $monitor_id $workspace)
}

split_move_to_workspace_silent() {
  workspace=$1

  monitor_id=$(hyprctl activeworkspace -j | jq '.monitorID')
  monitor=$(hyprctl monitors -j | jq ".[] | select(.id==$monitor_id)")

  hyprctl dispatch movetoworkspacesilent $(get_workspace_from_monitor $monitor_id $workspace)
}

change_monitor() {
  quiet=$1
  value=$2

  monitor_id=$(hyprctl activeworkspace -j | jq '.monitorID')
  monitor=$(hyprctl monitors -j | jq ".[] | select(.id==$monitor_id)")

  monitor_count=$(hyprctl monitors -j | jq '. | length')

  delta=0
  if [ $value == "next" ] || [ $value == "+1" ]; then
    delta=1
  elif [ $value == "prev" ] || [ $value == "-1" ]; then
    delta=-1
  else
    if [ $DEBUG == true ]; then
      hyprctl notify 0 5000 "rgb(61afef)" "[awesome-workspaces] WARNING: Invalid monitor value: $value"
    fi
  fi

  if [ $value == "next" ] || [ $value == "prev" ] || [ $value == "+1" ] || [ $value == "-1" ]; then
    monitor_id=$(echo $monitor | jq -r '.id')
    next_monitor_index=$(((monitor_id + delta) % monitor_count))

    if [ $next_monitor_index -lt 0 ]; then
      next_monitor_index=$((next_monitor_index + monitor_count))
    fi

    next_monitor=$(hyprctl monitors -j | jq ".[$next_monitor_index]")
    next_workspace=$(echo $next_monitor | jq -r '.activeWorkspace')

    if [ $quiet == true ]; then
      hyprctl dispatch movetoworkspacesilent $next_workspace
    else
      hyprctl dispatch movetoworkspace $next_workspace
    fi
  fi
}

split_change_monitor_silent() {
  value=$1

  change_monitor true $value
}

split_change_monitor() {
  value=$1

  change_monitor false $value
}

if [ $# -eq 0 ] || [ $1 == "init" ]; then
  map_workspaces_to_monitors
  hyprctl notify -1 5000 "rgb(61afef)" "[awesome-workspaces] Initialized successfully!"
elif [ $1 == "refresh_mapping" ]; then
  map_workspaces_to_monitors
elif [ $1 == "workspace" ]; then
  split_workspace "${@:2}"
elif [ $1 == "movetoworkspace" ]; then
  split_move_to_workspace "${@:2}"
elif [ $1 == "movetoworkspacesilent" ]; then
  split_move_to_workspace_silent "${@:2}"
elif [ $1 == "changemonitor" ]; then
  split_change_monitor "${@:2}"
elif [ $1 == "changemonitorsilent" ]; then
  split_change_monitor_silent "${@:2}"
fi
