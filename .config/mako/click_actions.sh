#!/bin/bash

always_list_actions=true

id="$1"
actions=$(makoctl list | jq -rc ".data[0].[] | select(.id.data == $id) | .actions.data")
action_count=$(echo $actions | jq -rc ". | length")

if [ "$action_count" -eq "0" ]; then
  makoctl dismiss -n $id
elif [ "$action_count" -eq "1" ] && [ "$always_list_actions" = false ]; then
  makoctl invoke -n $id "$(echo $actions | jq -rc ". | keys[0]")"
else
  makoctl menu -n $id wofi -d -p "Select an action"
fi
