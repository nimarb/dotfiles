#/bin/bash

#for correct echo execution RUN WITH "sudo sh -c ./powersave.sh" OR AS ROOT (careful!)!
#powersaving config files
audio="/etc/modprobe.d/audio_power_save.conf"
nmiwatchdog="/etc/sysctl.d/disable_watchdog.conf"
pciruntime="/etc/udev/rules.d/pci_pm.rules"
vmdirtywb="/etc/sysctl.d/dirty_writeback.conf"
usbsuspend="/etc/udev/rules.d/usb_power_save.rules"

#copying power saving file

#intel hd audio power saving
if [ ! -d $audio ]; then
	sudo touch $audio
	sudo "echo "options snd_hda_intel power_save=1" > $audio"
	echo "Created Audio power save config"
fi	

#turning nmi watchdog off: CAUTION disables hadrware error debugging
if [ ! -d $nmiwatchdog ]; then
	sudo touch $nmiwatchdog
	sudo echo "kernel.nmi_watchdog = 0" > $nmiwatchdog
	echo "Disabled NMI Watchdog"
fi

#pci runtime power management
if [ ! -d $pciruntime ]; then
	sudo touch $pciruntime
	sudo echo 'ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"' > $pciruntime
	echo "Enabled PCI Runtime Power Management"
fi

#delay vm dirty writeback
if [ ! -d $vmdirywb ]; then
	sudo touch $vmdirtywb
	sudo echo "vm.dirty_writeback_centisecs = 1500" > $vmdirtywb
	echo "Increased VM Dirty Writeback delay"
fi

#enable USB Auto Suspend
if [ ! -d $usbsuspend ]; then
	sudo touch $usbsuspend
	sudo echo 'ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control" ATTR{power/control}="auto"' > $usbsuspend
	sudo echo 'ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="2"' >> $usbsuspend
	echo "Enabled USB Auto Suspend with 2sec delay"
fi

