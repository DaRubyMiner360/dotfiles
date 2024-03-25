#!/bin/bash

# hyprctl clients -j | jq '.[] | select(.workspace.id != -1 and .workspace.id != 0 and (.workspace.name | startswith("special:lockdown") | not))'
# hyprctl clients -j | jq '.[] | select(.workspace.id != -1 and .workspace.id != 0 and (.workspace.name | startswith("special:lockdown")))'


# hyprctl clients -j | jq '.[] | select(.workspace.id != -1 and .workspace.id != -2 and (.workspace.name | startswith("special:lockdown") | not)) | .pid'
# hyprctl dispatch movetoworkspacesilent special:lockdown[R|S][ID],pid:[PID] # R for regular workspaces, S for special workspaces, ID for workspace ID for regular workspaces, ID for special workspace name for special workspaces, PID for process ID
