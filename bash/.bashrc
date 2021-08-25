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
HISTSIZE=
HISTFILESIZE=
HISTTIMEFORMAT='%Y-%m-%d %T: '
HISTIGNORE='ls:history:yay:pacdate:exit'
# save history immediately to file
#PROMPT_COMMAND='history -a'
PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND} ;}history -a";
# save cmds one cmd per line
shopt -s cmdhist

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

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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

######### Use modern alternatives of the standard unix commands ##########
# use lsd instead of ls if available
#if $(command -v lsd >/dev/null 2>&1) ; then
#   alias ls='lsd'
#fi
# use fd instead of find if available
#if $(command -v fd >/dev/null 2>&1) ; then
#   alias find='fd'
#fi
#########

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

# enable QT5 wayland backend
# export QT_QPA_PLATFORM_PLUGIN_PATH=/usr/lib/qt/plugins
export QT_QPA_PLATFORM=wayland-egl
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export GDK_BACKEND=wayland
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl
export _JAVA_AWT_WM_NONREPARENTING=1

# for good appindicatior support (tray icons) and support screen sharing
export XDG_CURRENT_DESKTOP=sway

# to support screen sharing
export XDG_SESSION_TYPE=wayland

# make firefox accept links to wayland instance when triggered from x11
export MOZ_DBUS_REMOTE=1
export MOZ_ENABLE_WAYLAND=1

# start programs in wayland mode
alias chrome="chromium-snapshot-bin --enable-features=UseOzonePlatform --enable-gpu --ozone-platform=wayland"
alias signal='signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland'

# alias for todo.txt todo app
alias t='todo.sh -antc'

# pacman install alias
alias pacget='sudo pacman -S'

# pacman search alias
alias pacs='pacsearch'

# git shortcuts
alias gits='git status'
alias guncommit='git reset --soft HEAD~'
# pulls the remote branch with the same name as the local branch
alias gitpull='git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gitpush="git push origin HEAD"
alias gitl='git log --all --decorate --oneline --graph'
alias gitf='git fetch --all'

# gpg related
alias gpt='gpg-tui -a -s colored'


# simple youtube play. Since yt 4k you need to stream vid and audio seperately
yplay() {
    YTDL_OUT=$(youtube-dl "$1" --get-url);
    URLS=($(echo "$YTDL_OUT" | tr ',' '\n'))
    vlc "${URLS[0]}" --input-slave "${URLS[1]}"
}

# search youtube and play best audio version with mpv
function yta() {
    mpv --keep-open --loop --ytdl-format=bestaudio ytdl://ytsearch:"$*"
}

# show active network connections
alias conns='ss -tan'
alias connsd='ss -ta'
alias ports='ss -tulanp'
alias procports='sudo ss -tulanp'

# grep pdf's
pdfgrep () { find . -name '*.pdf' -exec bash -c "pdftotext '{}' - | grep -i --with-filename --label='{}' --color '$*'" \; ;}

# gs pdfmerge !!DOES NOT WORK WITH SPACES IN FILENAME?!!
pdfgsmerge () { gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=merged.pdf $* ;}

# compresses a pdf using ghostcript
pdfcompress() { ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed.pdf -q -dNOPAUSE -dBATCH -dSAFER -dPDFA=2 -dPDFACompatibilityPolicy=1 -dSimulateOverprint=true -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dPDFSETTINGS=/screen -dEmbedAllFonts=true -dSubsetFonts=true -dAutoRotatePages=/None -dColorImageDownsampleType=/Bicubic -dColorImageResolution=150 -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=150 -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=150 $1 ;}

# extracts pages out of a pdf
pdfextract() { gs -dBATCH -sOutputFile=extracted_p$2-p$3.pdf -dFirstPage=$2 -dLastPage=$3 -sDEVICE=pdfwrite $1 ;}

# to make all PDF scan functions work, make sure gs >= 9.24 and adjust the
# imagemagick policies, as written here: https://stackoverflow.com/questions/52998331/imagemagick-security-policy-pdf-blocking-conversion

# makes the input PDF look as if it has been scanned. Outputs to
# $filename_scanned.pdf appending small or bad for the other cases.
pdfscan() {
    OUT=$(basename "$1" .pdf)
    convert -density 150 "$1" -colorspace gray -linear-stretch 3.5%x10% \
            -blur 0x0.5 -attenuate 0.25 +noise Gaussian -rotate 0.5 temp.pdf
    gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite \
       -sColorConversionStrategy=LeaveColorUnchanged \
       dAutoFilterColorImages=true -dAutoFilterGrayImages=true \
       -dDownsampleMonoImages=true -dDownsampleGrayImages=true \
       -dDownsampleColorImages=true -sOutputFile="$OUT"_scanned.pdf temp.pdf
    rm temp.pdf
}

# takes a pdf and produces an output which looks like it has been scanned.
# src: https://gist.github.com/andyrbell/25c8632e15d17c83a54602f6acde2724
pdfscanimg() {
    OUT=$(basename "$1" .pdf)
    convert -density 150 "$1" -rotate "$([ $((RANDOM % 2)) -eq 1 ] && echo -)0.$((RANDOM % 4 + 5))" \
        -attenuate 0.4 +noise Multiplicative -attenuate 0.03 +noise Multiplicative -sharpen 0x1.0 \
        -colorspace Gray "$OUT"_scanned.pdf
}

pdfscansmall() {
    OUT=$(basename "$1" .pdf)
    convert "$1" -alpha Off -density 150 -colorspace gray -blur 0.5x0.5 \
            -rotate 0.4 -level 40%,60% "$OUT"_scanned-small.pdf
}

pdfscannbad() {
    OUT=$(basename "$1" .pdf)
    convert "$1" -colorspace gray \( +clone -blur 0x1 \) +swap -compose divide \
            -composite -linear-stretch 5%x0% -rotate 1.5 "$OUT"_scanned-bad.pdf
}

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

# grep through all file types with fzf
rga-fzf() {
    RG_PREFIX="rga --files-with-matches"
    local file
    file="$(
	FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
	    fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
	    --phony -q "$1" \
	    --bind "change:reload:$RG_PREFIX {q}" \
	    --preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	    xdg-open "$file"
}
alias rgaf='rga-fzf'

# pretty print json output
ppjson () { echo "$1" | python -m json.tool ;}
alias prettyjson='python -m json.tool'

# inspect a json (all in the current dir) live with jq and fzf for preview
jsoninspect() {
    echo '' | fzf --print-query --preview "cat *.json | jq {q}"
}

# show disk use of subdirs sorted by size
alias subdirsize='du -d 1 -h | sort -hr | egrep -v ^0'

# find files with names which cant be used on exfat/ntfs
findbadnames() { find . -name '*[?<>\\:*|\"]*' ;}

# get synonyms from thesaurus.com
the() { ~/ext-progs/synonym/synonym "$1" ;}

# check dirty/writeback memory
alias watchdirty='watch -d -n 1 grep -e Dirty: -e Writeback: /proc/meminfo'

# restart service
alias sysrestart='sudo systemctl restart'
# start service
alias sysstart='sudo systemctl start'
# stop service
alias sysstop='sudo systemctl stop'
# service status
alias sysstatus='sudo systemctl status'
# reload daemons
alias sysreload='sudo systemctl daemon-reload'
# go sleep 
alias susp='systemctl suspend'

# aliases for x11 only apps (electron based) to run in wayland
alias vscode='GDK_BACKEND=x11 code'
alias vsnote='GDK_BACKEND=x11 code ~/nextcloud/daten/notes'
alias vsthought='GDK_BACKEND=x11 code ~/nextcloud/daten/thoughtson'
alias virtualbox='GDK_BACKEND=x11 virtualbox'

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

    # catkin make on arch
    alias catm='catkin_make -DPYTHON_EXECUTABLE=/usr/bin/python2 -DPYTHON_INCLUDE_DIR=/usr/include/python2.7 -DPYTHON_LIBRARY=/usr/lib/libpython2.7.so'
fi


# if cv-lab diary exists, make alias to open it
if [ -f "$HOME/Nextcloud/tohoku_18/cv-research-lab_diary.md" ]; then
    alias labd='vim ~/Nextcloud/tohoku_18/cv-research/lab_diary.md'
fi

# if work notebook exists, make alias to open it
if [ -f "$HOME""/nextcloud/daten/notes/knister/work-nb.md" ]; then
    alias wnb='vim ~/nextcloud/daten/notes/knister/work-nb.md'
fi

if [ "$HOSTNAME" = "this-pc" ]; then
    unalias t
    alias t='todo-txt -antc'
    # append local executables to path
    PATH="${PATH:+${PATH}:}$HOME/.local/bin"
    # prepend local exec's to path -> overwrites sys cmds and might be dangerous
    # PATH="~/.local/bin${PATH:+:${PATH}}"
fi

# Source cargo for a manual rustup installation
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
