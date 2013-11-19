#!/bin/bash
# shell script to set default sound device to usb DAC, if attached
# gets called through udev rule upon usb attachment/detachment

usbdac=$(asoundconf list | sed -n '3{p;q}')
intelhda=$(asoundconf list | sed -n '2{p;q}')

if [[ "attached" == "$1" ]]; then
	asoundconf set-default-card $usbdac
	#echo "$usbdac set as default audio card :)!"
	exit 1
fi

if [[ "detached" == "$1" ]]; then
	asoundconf set-default-card $intelhda
	#echo "intelhda set as default audio card :)!"
	exit 1
fi

