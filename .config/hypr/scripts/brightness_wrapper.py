#!/bin/python3

import sys
import subprocess

import click
from pydbus import SessionBus

# dbus setup
bus = SessionBus()
svc_proxy = bus.get('net.zoidplex.wlr_gamma_service',
        '/net/zoidplex/wlr_gamma_service')
brightnessctl = svc_proxy['net.zoidplex.wlr_gamma_service.brightness']

def get_gamma():
    return round(brightnessctl.get(), 2)

def set_gamma(gamma):
    return round(brightnessctl.set(gamma), 2)

def run_command(command):
    return subprocess.run(command, stdout=subprocess.PIPE, shell=True).stdout.decode('utf-8')[:-1]

def do_operation(first, sign, second):
    if sign == '=':
        return second
    if sign == '-':
        return first - second
    return first + second

def combined_percent(brightness, gamma):
    return round((brightness + (gamma * 50)) / 3 * 2)

def separated_percent(combined):
    if combined == 0:
        return (0, 0.00)
    if combined > 33:
        return (min(round((combined - 33) / 2 * 3), 100), 1.00)
    return (1, float(combined / 2 * 3 / 50))

current = run_command("brightnessctl -m | cut -d, -f4")
current_value = int(current[:-1])
gamma = get_gamma()

if len(sys.argv) < 2 or sys.argv[1] == "combined":
    print(combined_percent(current_value, gamma))
    exit()
elif sys.argv[1] == "brightness":
    print(current_value)
    exit()
elif sys.argv[1] == "gamma":
    print(gamma)
    exit()

change = sys.argv[1]
if "+" not in change and "-" not in change and "=" not in change:
    change = change + "="

change_value = int(change[:-2])
change_type = change[-1]
result = do_operation(current_value, change_type, change_value)

if change_type == "=":
    separated = separated_percent(result)

    run_command("brightnessctl set " + str(separated[0]) + "%")
    set_gamma(separated[1])
elif current_value != 0 and not (current_value == 1 and change_type == "-") and gamma == 1.0:
    if result <= 0 and change_type == "-":
        run_command("brightnessctl set 1%")
        set_gamma(0.99)
    else:
        run_command("brightnessctl set " + change)
elif gamma == 0.1 and change_type == "-":
    run_command("brightnessctl set 0%")
elif current_value == 0 and change_type == "+":
    run_command("brightnessctl set 1%")
else:
    if gamma == 0.99 and change_type == "+":
        set_gamma(1.0)
        run_command("brightnessctl set " + str(change_value - 1) + "%" + change_type)
    else:
        if change_value > 5:
            amount = 0.2
        elif change_value <= 5:
            amount = 0.1
        if gamma == 0.99 and change_type == "-":
            amount -= 0.01
        new_gamma = do_operation(gamma, change_type, amount)
        if new_gamma < 0.1:
            new_gamma = 0.1
        elif new_gamma >= 1.0:
            new_gamma = 0.99

        set_gamma(new_gamma)
run_command("~/.config/hypr/scripts/brightness --change")
