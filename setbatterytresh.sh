#!/bin/bash

#this sets the thinkpad's battery stop charging treshold to the desired %
sudo sh -c 'echo 80 > /sys/devices/platform/smapi/BAT0/stop_charge_thresh'
sudo sh -c 'echo 60 > /sys/devices/platform/smapi/BAT0/start_charge_thresh'
