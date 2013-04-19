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
