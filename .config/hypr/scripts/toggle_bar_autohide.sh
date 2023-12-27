if [ $(eww get autohide) = true ]; then
  eww update autohide=false
  for id in $(hyprctl monitors -j | jq -r '.[].id'); do
    eww close notch$id
    eww open bar$id
  done
else
  eww update autohide=true
  for id in $(hyprctl monitors -j | jq -r '.[].id'); do
    eww close bar$id
    eww open notch$id
  done
fi
