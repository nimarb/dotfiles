# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# sudo tab completion
complete -cf sudo

###########
# HISTORY
###########

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# history file, store everything forever
shopt -s histappend
# size of the history file on disk
HISTFILESIZE=
# size of the history stored in memory
HISTSIZE=
HISTTIMEFORMAT='%F %T: '
# Change the file loc because some bash sessions truncate .bash_history file on close.
export HISTFILE=~/.bash_eternal_history
HISTIGNORE='ls:history:yay:pacdate:exit'
# save history immediately to file
# PROMPT_COMMAND='history -a'
# logs every command also to a date versioned file in .logs
export PROMPT_COMMAND='if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/bash-history-$(date "+%Y-%m-%d").log; fi'
# save cmds one cmd per line
shopt -s cmdhist

###########
# END HISTORY
###########

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

# editor to vim
export EDITOR=vim

# enable QT5 wayland backend
# export QT_QPA_PLATFORM_PLUGIN_PATH=/usr/lib/qt/plugins
export QT_QPA_PLATFORM='wayland-egl'
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export GDK_BACKEND=wayland
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl
export _JAVA_AWT_WM_NONREPARENTING=1
export SDL_VIDEODRIVER=wayland
export SDL_DYNAMIC_API='/usr/lib/libSDL2-2.0.so'

# for good appindicatior support (tray icons) and support screen sharing
export XDG_CURRENT_DESKTOP=sway
# to support screen sharing
export XDG_SESSION_TYPE=wayland

# make firefox accept links to wayland instance when triggered from x11
export MOZ_DBUS_REMOTE=1
export MOZ_ENABLE_WAYLAND=1

# alias sway so that it will log
alias sway='WLR_RENDERER=vulkan sway --verbose 2> ~/sway.log'

# start programs in wayland mode
alias chromei="chromium-snapshot-bin --enable-features=UseOzonePlatform --enable-gpu --ozone-platform=wayland"
alias signal='signal-desktop --ozone-platform=wayland --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --disable-gpu'
alias infrax11='GDK_BACKEND=x11 infra'
alias infra='infra --ozone-platform=wayland --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer '
alias lseq='logseq --enable-features=UseOzonePlatform --ozone-platform=wayland'
alias slack='slack --ozone-platform=wayland --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer'
alias obsmd='obsidian --ozone-platform-hint=auto'

# env vars to support Fcitx5 IME in wayland/sway
# see also: https://github.com/swaywm/sway/pull/5890
# export GTK_IM_MODULE=fcitx5
# export QT_IM_MODULE=fcitx5

# export SSH sock to make ssh-agent via systemd work
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# alias for todo.txt todo app
alias t='todo.sh -antc'
alias tls='todo.sh -antc ls'
alias tlss='todo.sh -antc ls | grep +sento'

# alias for cal do display week numbers always
alias cal='cal -w'
alias call='cal -w -3'

# pacman install alias
alias pacget='sudo pacman -S'

# pacman search alias
alias pacs='pacsearch'
alias pacfiles='pacman -F'  # search which pkg contains a specific file

# Bind ALT-C to fcd to cd into dirs using fzfx
# TODO: doesn't work because cannot cd on enter
# bind '"\ec": " \C-e\C-u`fcd`\e\C-e\er\C-m"'

# remaining fzfx binds
alias ff='fzfx full' # full text search
alias fh='fzfx all' # hidden files
alias fcp='fzfx cp' # copy files
alias fmv='fzfx mv' # move files
alias fmd='fzfx md' # markdown files
alias fpdf='fzfx pdf' # pdf and postscript files
alias fav='fzfx media' # audio and videos
alias fpic='fzfx media' # pictures
alias fps='fzfx ps' # processes

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

# bluetoothctl alias
alias bctl='bluetoothctl'

# aliases for x11 only apps (electron based) to run in wayland
alias vscode='GDK_BACKEND=x11 code'
alias vsnote='GDK_BACKEND=x11 code ~/nextcloud/daten/notes'
alias vsthought='GDK_BACKEND=x11 code ~/nextcloud/daten/thoughtson'
alias virtualbox='GDK_BACKEND=x11 virtualbox'

# provide cat for images with sixel support in terminals
icatc() { convert "$1" -geometry "$(clc $COLUMNS*9)"x"$(clc $LINES*13)" sixel:- ;}
alias icat='chafa -f sixels'

# make poetry not request keyring access
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

# kubernetes k8s stuff
alias kctl='kubectl'
alias kpipesh='kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf | xargs -I{ppln} kubectl exec --stdin --tty {ppln} -- /bin/bash'
alias klistcont='kubectl get pods --all-namespaces -o jsonpath='\''{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}'\'' | sort'

if which loginctl > /dev/null && loginctl >& /dev/null; then
    if loginctl show-user | grep KillUserProcesses | grep -q yes; then
	echo "systemd is set to kill user processes on logoff"
	echo "This will break screen, tmux, emacs --daemon, nohup, etc"
	echo "To fix please set KillUserProcesses=no in /etc/systemd/login.conf"
    fi
fi

# source aliases
source ~/dotfiles/bash/aliases.sh

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

# on archtp480s, source k8s bash completion
if [ "$HOSTNAME" = "archtp480s" ]; then
    source <(kctl completion bash)
    complete -F __start_kubectl kctl
fi

# if cv-lab diary exists, make alias to open it
if [ -f "$HOME/Nextcloud/tohoku_18/cv-research-lab_diary.md" ]; then
    alias labd='vim ~/Nextcloud/tohoku_18/cv-research/lab_diary.md'
fi

# if work notebook exists, make alias to open it
if [ -f "$HOME""/nextcloud/daten/notes/knister/work-nb.md" ]; then
    alias wnb='vim ~/personal/notes/knister/work-nb.md'
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

# use git completion if available, perhaps arch specific
if [ -f "/usr/share/git/completion/git-completion.bash" ]; then
    source '/usr/share/git/completion/git-completion.bash'
fi

# Load pc specific aliases
if [ -f "$HOME/.local/share/scripts/aliases.bash" ]; then
    source "$HOME/.local/share/scripts/aliases.bash"
fi


# old way of getting FZF bindings:
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# by pynecone
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
