#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

#start network manager
/usr/bin/nm-applet --sm-disable &

#set up dual screens
IN="LVDS1"
EXT="DP1"
#if (xrandr | grep "$EXT" | grep "+")
if (xrandr | grep "$EXT" | grep " connected")
    then
    xrandr --output $EXT --auto --output $IN --off
    else
        if (xrandr | grep "$EXT" | grep " disconnected")
            then
            xrandr --output $IN --auto --output $EXT --off
        fi
fi

#enable scroll wheel simulation for middle mouse thinkbutton
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2

#start awesome
exec awesome
