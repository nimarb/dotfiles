[[ -o interactive ]] || return
source "${${(%):-%x}:A:h}/history-log.sh"

_dotfiles_history_zsh_preexec() {
  emulate -L zsh
  [[ -n $1 && $1 != ' '* ]] || return 0
  if [[ -n ${HISTORY_IGNORE:-} && $1 == ${~HISTORY_IGNORE} ]]; then
    return 0
  fi
  _dotfiles_history_write zsh start "$PWD" "$1"
}

# Retire only the exact old logger when ~/.zshrc is sourced in an existing shell.
# Other precmd functions and integrations must survive.
_dotfiles_history_legacy_precmd() { if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/zsh-history-$(date "+%Y-%m-%d").log; fi }
if [[ ${functions[precmd]-} == "${functions[_dotfiles_history_legacy_precmd]}" ]]; then
  unfunction precmd
fi
unfunction _dotfiles_history_legacy_precmd

autoload -Uz add-zsh-hook
add-zsh-hook preexec _dotfiles_history_zsh_preexec
