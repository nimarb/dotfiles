#!/bin/bash

#this sets the thinkpad's battery stop charging treshold to the desired %
sudo sh -c 'echo 100 > /sys/devices/platform/smapi/BAT0/stop_charge_thresh'
sudo sh -c 'echo 73 > /sys/devices/platform/smapi/BAT0/start_charge_thresh'
