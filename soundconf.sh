#!/bin/bash
# shell script to set default sound device to usb DAC, if attached
# gets called through udev rule upon usb attachment/detachment

usbdac=$(runuser -l nb -c 'asoundconf list' | sed -n '3{p;q}')
intelhda="PCH"

if [[ "attached" == "$1" ]]; then
	runuser -l nb -c 'asoundconf set-default-card $usbdac'
	#echo "$usbdac ($usbdac) set as default audio card :)!"
	exit 1
fi

if [[ "detached" == "$1" ]]; then
	runuser -l nb -c 'asoundconf set-default-card $intelhda'
	#echo "intelhda ($intelhda) set as default audio card :)!"
	exit 1
fi

