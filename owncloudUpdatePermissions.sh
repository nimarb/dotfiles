#!/bin/bash
# Sets permissions of the owncloud instance for updating

ocpath='/usr/share/webapps/owncloud'
htuser='http'
htgroup='http'

chown -R ${htuser}:${htgroup} ${ocpath}

