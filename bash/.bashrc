#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# sudo tab completion
complete -cf sudo

# history file
shopt -s histappend
HISTSIZE=2000
HISTFILESIZE=10000

# alias from mpd if it is installed as user
alias mpd='mpd ~/.mpd.conf'

# alias to always use more safe rm/mv (asks when deleting more than 3 things)
alias rm='rm -I'
alias mv='mv -i'

# alias for easyer pacman update
alias pacdate='sudo pacman -Syu'

# alias for untaring things
alias untar='tar -xvf'

# powertop alias
alias pwrtp='sudo powertop'

# make ls output readable for humans
alias lsl='ls -lh'

# creating an awk calculator invoked by clc ARGS
clc () { awk "BEGIN{ pi = 4.0*atan2(1.0,1.0); deg = pi/180.0; print $* }" ;}

# hex/dec conversion shortcut
alias h2d='printf "%d\n"'
alias d2h='printf "%x\n"'
alias h2b='printf "\$*" | xxd -b | cut -d" " -f2'

# editor to vim
export EDITOR=vim

# alias for todo.txt todo app
alias t='todo.sh -cAt'

# pacman install alias
alias pacget='sudo pacman -S'

# aur commands
alias aurget='pacaur --noedit -y'
alias aurdate='pacaur -k'
alias aurs='pacaur -s'

# pacman search alias
alias pacs='pacsearch'

# git shortcuts
alias gits='git status'

# catkin make on arch
alias catm='catkin_make -DPYTHON_EXECUTABLE=/usr/bin/python2 -DPYTHON_INCLUDE_DIR=/usr/include/python2.7 -DPYTHON_LIBRARY=/usr/lib/libpython2.7.so'

# simple youtube play
yplay () { vlc $(youtube-dl -ig $*) ;} 

# show active network connections
alias conns='ss -tan'
alias connsd='ss -ta'

# grep pdf's
pdfgrep () { find . -name '*.pdf' -exec bash -c "pdftotext '{}' - | grep -i --with-filename --label='{}' --color '$*'" \; ;}

# gs pdfmerge !!DOES NOT WORK WITH SPACES IN FILENAME?!!
pdfgsmerge () { gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=merged.pdf $* ;}

# pretty print json output
ppjson () { echo "$1" | python -m json.tool ;}
alias prettyjson='python -m json.tool'

# restart service
alias sysrestart='sudo systemctl restart'
# start service
alias sysstart='sudo systemctl start'
# service status
alias sysstatus='sudo systemctl status'
# reload daemons
alias sysreload='sudo systemctl daemon-reload'
# go sleep 
alias susp='systemctl suspend'

# alias for redshift, a screen temp adjuster like f.lux
alias flux='redshift-gtk &'

# for ros
if [ "$HOSTNAME" = "arch-tp" ]; then 
    source /opt/ros/kinetic/setup.bash
    unset PYTHONPATH
fi

#if [ "$TERMINOLOGY" = "1" ]
#then
#	t ls
#fi

