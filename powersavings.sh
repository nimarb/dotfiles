#/bin/bash

# ATTENTION!!: for correct echo execution RUN WITH "sudo sh -c ./powersave.sh" OR AS ROOT (careful!)!

# powersaving config files
audio="/etc/modprobe.d/audio_power_save.conf"
nmiwatchdog="/etc/sysctl.d/disable_watchdog.conf"
pciruntime="/etc/udev/rules.d/44-pci_pm.rules"
vmdirtywb="/etc/sysctl.d/dirty_writeback.conf"
usbsuspend="/etc/udev/rules.d/42-usb_power_save.rules"
localrules="/etc/udev/rules.d/91-local.rules"
wakeonlan="/etc/udev/rules.d/43-disable_wol.rules"
wlan="45-wlan_power_save.rules"
sata="/etc/udev/rules.d/47-sata_power_save.rules"

# copying power saving file

# intel hd audio power saving
if [ ! -a $audio ]; then
	sudo touch $audio
	sudo echo 'options snd_hda_intel power_save=1' > $audio
	echo "Created Audio power save config"
fi	

# turning nmi watchdog off: CAUTION disables hadrware error debugging
if [ ! -a $nmiwatchdog ]; then
	sudo touch $nmiwatchdog
	sudo echo 'kernel.nmi_watchdog = 0' > $nmiwatchdog
	echo "Disabled NMI Watchdog"
fi

# pci runtime power management
if [ ! -a $pciruntime ]; then
	sudo touch $pciruntime
	sudo echo 'ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"' > $pciruntime
	echo "Enabled PCI Runtime Power Management"
fi

# delay vm dirty writeback
if [ ! -a $vmdirywb ]; then
	sudo touch $vmdirtywb
	sudo echo 'vm.dirty_writeback_centisecs = 1500' > $vmdirtywb
	echo "Increased VM Dirty Writeback delay"
fi

# enable USB Auto Suspend
if [ ! -a $usbsuspend ]; then
	sudo touch $usbsuspend
	sudo echo 'ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control" ATTR{power/control}="auto"' > $usbsuspend
	sudo echo 'ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="2"' >> $usbsuspend
	echo "Enabled USB Auto Suspend with 2sec delay"
fi

# disable USB Auto Suspend for Logitech Devices, Microsoft Devices and Apple Devices
if [ ! -a $localrules ]; then
	sudo touch $localrules
	sudo echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="074b", TEST=="power/control", ATTR{power/control}="on"' > $localrules
	sudo echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c051", TEST=="power/control", ATTR{power/control}="on"' >> $localrules
	sudo echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", TEST=="power/control", ATTR{power/control}="on"' >> $localrules
	echo "Disabled USB Auto Suspend for Logitech, Apple and MS devices"
fi

# sata power management
if [ ! -a $sata ]; then
	sudo touch $sata
	sudo echo 'KERNEL=="AC*", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/home/nb/dotfiles/satapwrmngmnt.sh offline"' > $sata
	sudo echo 'KERNEL=="AC*", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/home/nb/dotfiles/satapwrmngmnt.sh online"' >> $sata
	echo "Enabled SATA Power Saving"
fi

# wake on lan disabled / power saving
if [ ! -a $wakeonlan ]; then
	sudo touch $wakeonlan
	sudo echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*" RUN+="/usr/bin/ethtool -s %k wol d"' > $wakeonlan
	echo "Disabled Wake On Lan"
fi

# enable wlan powersaving mode
if [ ! -a $wlan ]; then
	sudo touch $wlan
	sudo echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*" RUN+="/usr/bin/iw dev %k set power_save on"' > $wlan
	echo "Enabled WLAN Power Saving mode"
fi
