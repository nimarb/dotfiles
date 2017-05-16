#!/bin/bash
# setup file to set certain settings for a new archlinux installation

# check root
if [ "$(whoami)" != "root" ]; then
    echo "Sorry, run again as root, no files have been changed."
    exit 1
fi

# virtualbox
read -p "Always load VBox Host Modules (modprobe on every boot)? [y/n]" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
    echo vboxdrv > /etc/modules-load.d/virtualbox.conf
fi

# i3lock autolock after sleep
if [ -d /etc/systemd/system/ ]; then
    read -p "Always start i3lock after sleep (autolock after sleep with i3lock)? [y/]" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
	printf "[Unit] \nDescription=Lock X session using i3lock \nBefore=sleep.target \n\n[Service] \nUser=nb \nType=forking \nEnvironment=DISPLAY=:0 \nExecStart=/usr/bin/i3lock -d \n\n[Install] \nWantedBy=sleep.target \n" > /etc/systemd/system/lock-screen.service
    fi
fi

