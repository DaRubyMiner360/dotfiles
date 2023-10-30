if [ $(hyprctl activewindow -j | jq .workspace.name) = '"special"' ]; then
  hyprctl dispatch movetoworkspacesilent $(hyprctl activeworkspace -j | jq .id)
else
  hyprctl dispatch movetoworkspacesilent special
fi
