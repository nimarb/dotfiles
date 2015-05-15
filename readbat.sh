#!/bin/bash

date >> ~/batstats.txt
echo -e "Cycle_Count: $(cat /sys/devices/platform/smapi/BAT0/cycle_count)" >> ~/batstats.txt
echo -e "Current_Avg: $(cat /sys/devices/platform/smapi/BAT0/current_avg)" >> ~/batstats.txt
echo -e "Last_Full_Capacity: $(cat /sys/devices/platform/smapi/BAT0/last_full_capacity)" >> ~/batstats.txt
echo -e "Power_Avg: $(cat /sys/devices/platform/smapi/BAT0/power_avg)" >> ~/batstats.txt
echo -e "Remaining_Capacity: $(cat /sys/devices/platform/smapi/BAT0/remaining_capacity)" >> ~/batstats.txt
echo -e "State: $(cat /sys/devices/platform/smapi/BAT0/state)" >> ~/batstats.txt
echo -e "Temperature $(cat /sys/devices/platform/smapi/BAT0/temperature)" >> ~/batstats.txt
echo -e "Model: $(cat /sys/devices/platform/smapi/BAT0/model)" >> ~/batstats.txt
echo -e "Serial: $(cat /sys/devices/platform/smapi/BAT0/serial)" >> ~/batstats.txt
echo -e "Installed: $(cat /sys/devices/platform/smapi/BAT0/installed)" >> ~/batstats.txt
echo -e "Stop_Charge_Thresh: $(cat /sys/devices/platform/smapi/BAT0/stop_charge_thresh)" >> ~/batstats.txt
