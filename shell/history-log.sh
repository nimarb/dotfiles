# Shared writer for the interactive Zsh and Bash adapters. Requires jq.
# HISTORY_LOG_DIR can redirect the archive (for example, in isolated tests).

_dotfiles_history_warn() {
  if [ "${_dotfiles_history_warned:-}" != 1 ]; then
    printf '%s\n' "history archive: $1" >&2
    _dotfiles_history_warned=1
  fi
}

_dotfiles_history_init() {
  if [ "${_dotfiles_history_pid:-}" != "$$" ]; then
    _dotfiles_history_pid=$$
    _dotfiles_history_session="$(date -u '+%Y%m%dT%H%M%SZ')-$$-$RANDOM$RANDOM"
    _dotfiles_history_seq=0
    _dotfiles_history_warned=
  fi
}

_dotfiles_history_write() {
  # Arguments: shell, metadata timing, directory, submitted command.
  [ "$EUID" -ne 0 ] || return 0
  case "$4" in ''|' '*) return 0 ;; esac
  if ! command -v jq >/dev/null 2>&1; then
    _dotfiles_history_warn 'jq is required; command was not archived'
    return 0
  fi

  local timestamp archive_file archive_dir
  timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ') || return 0
  archive_dir=${HISTORY_LOG_DIR:-$HOME/.logs}
  archive_file="$archive_dir/$1-history-${timestamp%%T*}-${_dotfiles_history_session}.jsonl"
  _dotfiles_history_seq=$((_dotfiles_history_seq + 1))

  # One file per interactive session/day, so concurrent shells never share a
  # record stream. stdin avoids command-size limits and hand-written JSON escapes.
  if ! (
    umask 077
    mkdir -p -- "$archive_dir" || exit 1
    printf '%s\0' "$timestamp" "$1" "$_dotfiles_history_session" \
      "$_dotfiles_history_seq" "$2" "$3" "$4" |
      jq -Rsc 'split("\u0000") | {
        v: 1, time: .[0], shell: .[1], session: .[2], seq: (.[3] | tonumber),
        timing: .[4], cwd: .[5], command: .[6]
      }' >> "$archive_file"
  ); then
    _dotfiles_history_warn 'could not append a command to the archive'
  fi
  return 0
}

_dotfiles_history_init
