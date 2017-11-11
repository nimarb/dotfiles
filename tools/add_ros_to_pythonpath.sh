#!/usr/bin/bash

function check_root() {
    if [ "$(id -u)" != "0" ]
    then
	echo '[ERROR] must be root to use this script!'
	exit 1
    fi
}

check_root
if [ ! -e "/usr/lib/python2.7/site-packages/ros-path.pth" ]; then
    echo "/opt/ros/kinetic/lib/python2.7/site-packages" > /usr/lib/python2.7/site-packages/ros-path.pth
    echo "Done!, now you have to unset PYTHONPATH in your bashrc so that python3 works again"
fi
