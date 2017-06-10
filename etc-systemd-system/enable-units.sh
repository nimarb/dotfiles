#!/bin/bash

echo "has to be run as root and the unit files have to placed in"
echo "/etc/systemd/system/"

systemctl enable five-minute-timer.timer
systemctl start five-minute-timer.timer
systemctl enable BatteryStats.service
