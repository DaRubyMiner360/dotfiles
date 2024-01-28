#!/bin/bash

target=$1
use_relative_open=false
if [[ $target = e* ]]; then
  target=${target:1}
  use_relative_open=true
fi

active_workspace=$(hyprctl activeworkspace -j | jq '.id')
active_monitor=$(hyprctl activeworkspace -j | jq '.monitorID')
workspace_set=$(( (active_workspace - 1) / 100 ))

if [[ $use_relative_open = false ]]; then
  echo $(( active_workspace $target > workspace_set * 100 ? active_workspace $target < (workspace_set + 1) * 100 + 1 ? active_workspace $target : (workspace_set + 1) * 100 : workspace_set * 100 + 1 ))
else
  monitor_workspaces=$(hyprctl workspaces -j | jq "[.[] | select(.monitorID==$active_monitor) | select(.id > 0) | .id] | sort")
  monitor_workspace_count=$(echo $monitor_workspaces | jq "length")
  monitor_workspace_index=$(echo $monitor_workspaces | jq ". | index($active_workspace)")
  result_index=$(( (monitor_workspace_index $target) % monitor_workspace_count ))
  echo $monitor_workspaces | jq ".[$result_index]"
fi
