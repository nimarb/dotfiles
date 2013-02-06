#!/bin/bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles as well as further config files when added to the list
############################

# create vars
dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files="bashrc vimrc xinitrc"    # list of files/folders to symlink in homedir
awesomecfg="rc.lua"				# awesome wm config file
ncmpcppcfg="config"				# ncmpcpp config file

# create folder dotfiles_old in homedir and change to dotfiles
echo "Creating $olddir to backup existing dotfiles in ~"
mkdir -p $olddir
echo "...done"
echo "Changing to $dir"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
	    echo "Moving any existing dotfiles from ~ to $olddir"
		    mv ~/.$file $olddir/
			    echo "Creating symlink to $file in home dir"
				    ln -s $dir/$file ~/.$file
				done

# move awesome config file to .config/awesome/rc.lua if awesomeWM is installed!
if [ -d ~/.config/awesome ]; then
	echo "Moving awesomeWM config file to $olddir"
	mv ~/.config/awesome/$awesomecfg $olddir/
	echo "Creating symlink for awesomeWM config file"
	ln -s $dir/$awesomecfg ~/.config/awesome/$awesomecfg
fi

# if awesome is not installed, let the user know!
if [ ! -d ~/.config/awesome ]; then
	echo "awesomeWM appears not to be installed on this pc, config was not copied"
fi

# if ncmpcpp folder is created, try to move the config, too
if [ -d ~/.ncmpcpp ]; then
	if [ -f ~/.ncmpcpp/$ncmpcppcfg ]; then
		echo "Moving old ncmpcpp config to $olddir"
		mv ~/.ncmpcpp/$ncmpcppcfg $olddir
	fi
	echo "Creating symlink for ncmpcpp config file"
	ln -s $dir/$ncmpcppcfg ~/.ncmpcpp/$ncmpcppcfg
fi

