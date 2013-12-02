#!/bin/bash

#this sets the thinkpad's battery stop charging treshold to the desired %
sudo sh -c 'echo 95 > /sys/devices/platform/smapi/BAT0/stop_charge_thresh'
