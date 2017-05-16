#!/bin/bash
# script to set displays up correctly

IN="LVDS1"
EXTDP="DP1"
EXTVGA="VGA1"
EXTHDMI="HDMI1"
if (xrandr | grep "$EXTDP" | grep " connected")
    then
	if (xrandr | grep "$EXTVGA" | grep " connected")
	    then
		xrandr --output $IN --off
		xrandr --output $EXTDP --rate 60 --auto --output $EXTVGA --left-of $EXTDP --rate 60
	    else
		xrandr --output $EXTVGA --off
		xrandr --output $EXTDP --rate 60 --auto --output $IN --off 
	fi
    else
	xrandr --output $EXTDP --off
	if (xrandr | grep "$EXTVGA" | grep " connected")
	    then
		xrandr --output $IN --rate 60 --auto --output $EXTVGA --rate 60 --auto --left-of $IN
	    else
		xrandr --output $EXTVGA --off
		xrandr --output $EXTHDMI --off
		xrandr --output $IN --rate 60 --auto 
	fi
fi
if (xrandr | grep "$EXTHDMI" | grep " connected")
    then
	xrandr --output $EXTHDMI --rate 60 --auto
	xrandr --output $IN --off
fi
