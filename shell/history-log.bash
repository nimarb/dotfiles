[[ $- == *i* ]] || return
source "${BASH_SOURCE[0]%/*}/history-log.sh"

_dotfiles_history_bash_read() {
  # Read only the last accepted event. Its identity, not its command text alone,
  # distinguishes a newly accepted command from ignored input or an empty prompt.
  _dotfiles_history_entry=$(HISTTIMEFORMAT= builtin history 1)
}

_dotfiles_history_bash_capture() {
  local timing=$1 entry command_text
  _dotfiles_history_bash_read
  entry=$_dotfiles_history_entry
  if [[ -n $entry && $entry != "${_dotfiles_history_previous:-}" ]]; then
    command_text=${entry#*[0-9][* ] }
    _dotfiles_history_write bash "$timing" "$PWD" "$command_text"
  fi
  _dotfiles_history_previous=$entry
}

_dotfiles_history_bash_before() {
  local ret=$?
  _dotfiles_history_bash_capture start
  return "$ret"
}

_dotfiles_history_bash_prompt() {
  local ret=$?
  if [[ $_dotfiles_history_bash_mode == prompt ]]; then
    _dotfiles_history_bash_capture completion
  else
    # Imports/clears during a command must not be mistaken for the next command.
    _dotfiles_history_bash_read
    _dotfiles_history_previous=$_dotfiles_history_entry
  fi
  return "$ret"
}

_dotfiles_history_bash_install() {
  local old_logger hook i retired_old=
  old_logger='if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/bash-history-$(date "+%Y-%m-%d").log; fi'

  # Replace only the old archive command, retaining any appended integrations.
  if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == 'declare -a '* ]]; then
    for i in "${!PROMPT_COMMAND[@]}"; do
      [[ ${PROMPT_COMMAND[$i]} == *"$old_logger"* ]] && retired_old=1
      PROMPT_COMMAND[$i]=${PROMPT_COMMAND[$i]//"$old_logger"/:}
    done
  else
    [[ ${PROMPT_COMMAND:-} == *"$old_logger"* ]] && retired_old=1
    PROMPT_COMMAND=${PROMPT_COMMAND//"$old_logger"/:}
  fi
  if [[ $retired_old == 1 ]]; then
    # The legacy config exported this variable. Our callback functions belong to
    # this shell, so a child without this config must not inherit their names.
    export -n PROMPT_COMMAND
  fi

  _dotfiles_history_bash_read
  _dotfiles_history_previous=$_dotfiles_history_entry
  if (( BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 3) )); then
    _dotfiles_history_bash_mode=preexec
    hook='${ _dotfiles_history_bash_before; }'
    [[ ${PS0:-} == *"$hook"* ]] || PS0=${PS0:-}$hook
  else
    # Older Bash has no equivalent current-environment pre-command callback.
    # Record accepted history at the next prompt and label its metadata honestly.
    _dotfiles_history_bash_mode=prompt
  fi

  if [[ ${PROMPT_COMMAND[*]:-} != *'_dotfiles_history_bash_prompt'* ]]; then
    if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == 'declare -a '* ]]; then
      PROMPT_COMMAND+=(_dotfiles_history_bash_prompt)
    else
      PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}_dotfiles_history_bash_prompt
    fi
  fi
}

_dotfiles_history_bash_install
