export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="/Users/nb/.local/bin:$PATH"

autoload -Uz compinit && compinit
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/opt/homebrew/opt/go@1.23/bin:$PATH"

# use new bash as default via homebrew
export PATH="/opt/homebrew/opt/bash/bin:$PATH"

# to run global bun executables such as QMD by tobi
export PATH="/Users/nb/.bun/bin:$PATH"

# Option+C: include hidden folders, respect ignore files and skip paths containing "cache".
export FZF_ALT_C_COMMAND='fd --type d --follow --hidden --exclude .git --exclude node_modules --exclude "*[cC][aA][cC][hH][eE]*"'


###########
# HISTORY
###########

# don't put duplicate lines or lines starting with space in the history.
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS

# history file is updated immediately after a command is entered (muddies the history between open shells)
# setopt INC_APPEND_HISTORY
# allows multiple Zsh sessions to share the same command history
setopt SHARE_HISTORY
# records the time when each command was executed along with the command itself
setopt EXTENDED_HISTORY
# each command entered in the current session is appended to the history on shell exit
setopt APPEND_HISTORY

# size of the history file on disk
HISTFILESIZE=1000000000
# size of the history stored in memory
HISTSIZE=1000000000
# zsh saves this many lines from the in-memory history list to the history file upon shell exit
SAVEHIST=500000

HISTTIMEFORMAT='%F %T: '

# Change the file loc because some zsh sessions truncate .zsh_history file on close.
export HISTFILE=~/.zsh_eternal_history
HISTFILE=~/.zsh_eternal_history

HISTORY_IGNORE="(ls|history|yay|pacdate|exit|bup)"

# Archive each eligible command once, separately from native Ctrl-R history.
source ~/dotfiles/shell/history-log.zsh

# save cmds one cmd per line
#shopt -s cmdhist

###########
# END HISTORY
###########
