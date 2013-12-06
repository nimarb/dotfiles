#!/bin/bash

if [[ "offline" == $1 ]]; then
	echo 'min_power' > /sys/class/scsi_host/host0/link_power_management_policy
	echo 'min_power' > /sys/class/scsi_host/host1/link_power_management_policy
	echo 'min_power' > /sys/class/scsi_host/host2/link_power_management_policy
	echo 'min_power' > /sys/class/scsi_host/host3/link_power_management_policy
	echo 'min_power' > /sys/class/scsi_host/host4/link_power_management_policy
	echo 'min_power' > /sys/class/scsi_host/host5/link_power_management_policy
	exit 1
fi

if [[ "online" == $1 ]]; then
	echo '' > /sys/class/scsi_host/host0/link_power_management_policy
	echo '' > /sys/class/scsi_host/host1/link_power_management_policy
	echo '' > /sys/class/scsi_host/host2/link_power_management_policy
	echo '' > /sys/class/scsi_host/host3/link_power_management_policy
	echo '' > /sys/class/scsi_host/host4/link_power_management_policy
	echo '' > /sys/class/scsi_host/host5/link_power_management_policy
	exit 1
fi
