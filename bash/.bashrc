#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# sudo tab completion
complete -cf sudo

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# history file
shopt -s histappend
HISTSIZE=2000000
HISTFILESIZE=3000000
HISTTIMEFORMAT='%Y-%m-%d %T: '

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# make grep colourful
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# alias from mpd if it is installed as user
alias mpd='mpd ~/.mpd.conf'

# alias to always use more safe rm/mv (asks when deleting more than 3 things)
alias rm='rm -I'
alias mv='mv -i'

# make a new dir with the current date as name
alias mdd='mkdir $(date -I)'

# clones a git dir without fsck'ing contents --> for old repos & new git
alias gitc-nofsck='git clone --config transfer.fsckobjects=false --config receive.fsckobjects=false --config fetch.fsckobjects=false'

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
alias t='todo.sh -antc'

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
alias ports='ss -tulanp'

# grep pdf's
pdfgrep () { find . -name '*.pdf' -exec bash -c "pdftotext '{}' - | grep -i --with-filename --label='{}' --color '$*'" \; ;}

# gs pdfmerge !!DOES NOT WORK WITH SPACES IN FILENAME?!!
pdfgsmerge () { gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=merged.pdf $* ;}

# find and grep
function fgr {
    NAM=""
    GREPTYPE="-i -H"
    if [ -n "$1" ]; then
	test -n "$2" && NAM="-name \"$2\""
	test -n "$3" && GREPTYPE=$3
	CMMD="find . $NAM -not -path '*/\.*' -exec egrep --colour=auto $GREPTYPE \"$1\" {} + 2>/dev/null"
	>&2 echo -e "Running: $CMMD\n"
	sh -c "$CMMD"
	echo ""
    else
	echo -e "Expected: fgr <search> [file filter] [grep opt]\n"
    fi
}

# pretty print json output
ppjson () { echo "$1" | python -m json.tool ;}
alias prettyjson='python -m json.tool'

# show disk use of subdirs sorted by size
alias subdirsize='du -d 1 -h | sort -hr | egrep -v ^0'

# find files with names which cant be used on exfat/ntfs
findbadnames() { find . -name '*[?<>\\:*|\"]*' ;}

# check dirty/writeback memory
alias watchdiry='watch -d -n 1 grep -e Dirty: -e Writeback: /proc/meminfo'

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

##################
# COMPUTER SPECIFIC THINGS
##################
# for ros
if [ "$HOSTNAME" = "arch-tp" ]; then 
    source /opt/ros/kinetic/setup.bash
    unset PYTHONPATH
fi

# if cv-lab diary exists, make alias to open it
if [[ -f ~/Nextcloud/tohoku_18/cv-research/lab_diary.md ]]; then
    alias labd='vim ~/Nextcloud/tohoku_18/cv-research/lab_diary.md'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
  fi
fi

