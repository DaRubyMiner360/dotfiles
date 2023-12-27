#!/bin/bash

batteries=$(ls /sys/class/power_supply/ | grep '^BAT')

capacity="0"
text="No Batteries Found"
status="Not charging"

if [ ! -z "$batteries" ]; then
  first_battery=$(echo $batteries | cut -d' ' -f1)

  capacity="$(cat /sys/class/power_supply/$first_battery/capacity)"
  text="$capacity%"
  status="$(cat /sys/class/power_supply/$first_battery/status)"
fi

jq -n "{capacity: $capacity, text: \"$text\", status: \"$status\"}"
