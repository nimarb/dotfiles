#/bin/bash

#installs default packages for archlinux
#file containing the std pkgs

stdpkgs=stdpkg.txt

if [ uname -r  ]; then
	echo "Installation of Arch Linux found, continuing to install pkgs..."
fi
