#!/bin/bash

# Example usage: move_to_workspace.sh SUPER 0

workspace_set=$1
mod_key=${2:-SUPER}

for i in {1..10}; do
  workspace=$((workspace_set * 10 + i))
  key=$i
  if [ $i = 10 ]; then
    key=0
  fi
  hyprctl keyword unbind $mod_key, $key
  hyprctl keyword unbind $mod_key SHIFT, $key

  hyprctl keyword bind $mod_key, $key, exec, ~/.config/hypr/scripts/awesome_workspaces.sh workspace $workspace
  hyprctl keyword bind $mod_key SHIFT, $key, exec, ~/.config/hypr/scripts/awesome_workspaces.sh movetoworkspace $workspace
  # hyprctl keyword bind $mod_key, $key, split-workspace, $workspace
  # hyprctl keyword bind $mod_key SHIFT, $key, split-movetoworkspace, $workspace
done
