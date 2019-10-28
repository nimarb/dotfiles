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
HISTSIZE=100000
HISTFILESIZE=200000
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
alias t='todo-txt -antc'

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

# compresses a pdf using ghostcript
pdfcompress() { ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed.pdf -q -dNOPAUSE -dBATCH -dSAFER -dPDFA=2 -dPDFACompatibilityPolicy=1 -dSimulateOverprint=true -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dPDFSETTINGS=/screen -dEmbedAllFonts=true -dSubsetFonts=true -dAutoRotatePages=/None -dColorImageDownsampleType=/Bicubic -dColorImageResolution=150 -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=150 -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=150 $1 ;}

# extracts pages out of a pdf
pdfextract() { gs -dBATCH -sOutputFile=extracted_p$2-p$3.pdf -dFirstPage=$2 -dLastPage=$3 -sDEVICE=pdfwrite $1 ;}

# pretty print json output
ppjson () { echo "$1" | python -m json.tool ;}
alias prettyjson='python -m json.tool'

# find files with names which cant be used on exfat/ntfs
findbadnames() { find . -name '*[?<>\\:*|\"]*' ;}

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

if which loginctl > /dev/null && loginctl >& /dev/null; then
    if loginctl show-user | grep KillUserProcesses | grep -q yes; then
	echo "systemd is set to kill user processes on logoff"
	echo "This will break screen, tmux, emacs --daemon, nohup, etc"
	echo "To fix please set KillUserProcesses=no in /etc/systemd/login.conf"
    fi
fi

##################
# COMPUTER SPECIFIC THINGS
##################
# for ros
if [ "$HOSTNAME" = "arch-tp" ]; then 
    source /opt/ros/kinetic/setup.bash
    unset PYTHONPATH
fi

# if cv-lab diary exists, make alias to open it
if [ -f "~/Nextcloud/tohoku_18/cv-research-lab_diary.md" ]; then
    alias labd='vim ~/Nextcloud/tohoku_18/cv-research/lab_diary.md'
fi


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
