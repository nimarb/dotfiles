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

# start network manager
/usr/bin/nm-applet --sm-disable &

# load Xresources file
xrdb ~/.Xresources

# set up dual screens/single screen
IN="LVDS1"
EXTDP="DP1"
EXTVGA="VGA1"
if (xrandr | grep "$EXTDP" | grep " connected")
    then
		if (xrandr | grep "$EXTVGA" | grep " connected")
		then
			xrandr --output $IN --off
			xrandr --output $IN --off --output $EXTDP --rate 60 --auto --output $EXTVGA --left-of $EXTDP --rate 60
		else
			xrandr --output $EXTVGA --off
    		xrandr --output $EXTDP --rate 60 --auto --output $IN --off 
		fi
	else
		xrandr --output $EXTDP --off
		if (xrandr | grep "$EXTVGA" | grep " connected")
		then
			xrandr --output $IN --auto --output $EXTVGA --rate 60 --auto --left-of $IN
		else
			xrandr --output $IN --auto --output $EXTVGA --off
		fi
fi

# enable scroll wheel simulation for middle mouse thinkbutton
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2

# start awesome
exec awesome

# Execute shell script which starts gpg-agent
eval $(gpg-agent --daemon) &

# start e17
#exec enlightenment_start
