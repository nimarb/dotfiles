#!/bin/bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles as well as further config files when added to the list
############################

# create vars
dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files="bashrc vimrc xinitrc"    # list of files/folders to symlink in homedir
awesomecfg="rc.lua"				# awesome wm config file

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
		    mv ~/.$file ~/$olddir/
			    echo "Creating symlink to $file in home dir"
				    ln -s $dir/$file ~/.$file
				done

# move awesome config file to .config/awesome/rc.lua
echo "Moving awesomeWM config file to $olddir"
mv ~/.config/awesome/$awesomecfg ~/$olddir
echo "Creating symlink for awesomeWM config file"
ln -s $dir/$awesomecfg ~/.config/awesome/$awesomecfg

echo "Completed successfully! :)"
