#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

#sudo tab completion
complete -cf sudo

#alias from mpd if it is installed as user
alias mpd='mpd ~/.mpd.conf'

#alias to always use more safe rm (asks when deleting 3 files or more)
alias rm='rm -I'

#alias for easyer pacman update
alias pacdate='sudo pacman -Syu'

#alias for untaring things
alias untar='tar -xvf'

#powertop alias
alias pwrtp='sudo powertop'

#creating an awk calculator invoked by clc ARGS
clc () { awk "BEGIN{ pi = 4.0*atan2(1.0,1.0); deg = pi/180.0; print $* }" ;}
