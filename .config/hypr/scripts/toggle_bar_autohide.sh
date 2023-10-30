if [ $(eww get autohide) = true ]; then
  eww update autohide=false
  eww close notch
  eww open bar
else
  eww update autohide=true
  eww close bar
  eww open notch
fi
