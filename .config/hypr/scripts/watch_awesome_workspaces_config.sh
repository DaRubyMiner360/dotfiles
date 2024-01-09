#!/bin/bash

while true; do
  watch --chgexit -n 1 "cat ~/.config/hypr/scripts/awesome_workspaces.sh" && ~/.config/hypr/scripts/awesome_workspaces.sh refresh_mapping
  sleep 1
done
