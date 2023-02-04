#!/bin/bash

echo "has to be run as root and the unit files have to placed in"
echo "/etc/systemd/system/"

echo "enabling battery stats"
systemctl enable five-minute-timer.timer
systemctl start five-minute-timer.timer
systemctl enable BatteryStats.service

echo "enabling seatd for sway to work"
systemctl start seatd
systemctl enable seatd
systemctl status seatd
