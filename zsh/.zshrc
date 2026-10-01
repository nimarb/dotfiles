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

# live grep current dir with fzf + rg + bat
fzg() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzg: fzf required" >&2
    return 1
  fi
  if ! command -v rg >/dev/null 2>&1; then
    echo "fzg: rg required" >&2
    return 1
  fi
  if ! command -v bat >/dev/null 2>&1; then
    echo "fzg: bat required" >&2
    return 1
  fi

  local query="${*:-}"
  local preview_lines
  preview_lines=$(( $(tput lines 2>/dev/null || echo 24) - 2 ))
  if [ "$preview_lines" -lt 3 ]; then
    preview_lines=3
  fi
  local reload_cmd='[[ -n {q} ]] && rg --fixed-strings --column --line-number --no-heading --hidden --no-ignore --smart-case --color=always --glob "!.git" --glob "!.git/**" --glob "!node_modules" --iglob "!*cache*" {q} . || true'
  local preview_cmd='file={1}; [ -n "$file" ] && [ -f "$file" ] || exit 0
line={2}; col={3}; query={q}
if [ "$FZF_PREVIEW_LABEL" = "Formatted | Ctrl+V: raw" ] && command -v jq >/dev/null 2>&1; then
  if formatted=$(jq --monochrome-output . -- "$file" 2>/dev/null) && [ -n "$formatted" ] && [ -n "$query" ]; then
    # Match the selected occurrence after formatting changes the line numbers.
    occurrence=$(rg --only-matching --line-number --column --no-filename --color=never --fixed-strings --smart-case -- "$query" "$file" |
      awk -F: -v line="$line" -v col="$col" '"'"'$1 < line || ($1 == line && $2 <= col) { n++ } END { print n+0 }'"'"')
    formatted_line=$(printf "%s\n" "$formatted" |
      rg --only-matching --line-number --color=never --fixed-strings --smart-case -- "$query" |
      awk -F: -v n="$occurrence" '"'"'NR == n { print $1; exit }'"'"')
    if [ -n "$formatted_line" ]; then
      start=$((formatted_line > 3 ? formatted_line - 3 : 1))
      printf "%s\n" "$formatted" |
        rg --passthru --fixed-strings --smart-case --color=always --colors match:bg:yellow --colors match:fg:black -- "$query" |
        bat --paging=never --language=json --style=numbers --color=always --line-range "$start:"
      exit 0
    fi
  fi
fi
qlen=${#query}; [ "$qlen" -gt 0 ] || qlen=1; perl -CS -e '"'"'
use utf8;
my ($file, $target_line, $col, $qlen) = @ARGV;
$qlen = 1 if !$qlen || $qlen < 1;
open my $fh, "<:encoding(UTF-8)", $file or exit 1;
my $current = 0;
my $text = "";
while (my $line = <$fh>) {
  ++$current;
  next unless $current == $target_line;
  chomp $line;
  $text = $line;
  last;
}
my $len = length($text);
my $width = 160;
my $start = $col - 60;
$start = 1 if $start < 1;
my $max_start = $len - $width + 1;
$max_start = 1 if $max_start < 1;
$start = $max_start if $start > $max_start;
my $prefix = $start > 1 ? "…" : "";
my $take = $width - length($prefix);
$take = 40 if $take < 40;
my $snippet = substr($text, $start - 1, $take);
my $suffix = ($start - 1 + length($snippet) < $len) ? "…" : "";
my $hit_start = $col - $start;
$hit_start = 0 if $hit_start < 0;
$hit_start = length($snippet) - 1 if length($snippet) > 0 && $hit_start >= length($snippet);
my $hit_len = $qlen;
$hit_len = length($snippet) - $hit_start if $hit_start + $hit_len > length($snippet);
$hit_len = 1 if $hit_len < 1;
my $before = substr($snippet, 0, $hit_start);
my $hit = substr($snippet, $hit_start, $hit_len);
my $after = substr($snippet, $hit_start + $hit_len);
print "focus > ", $prefix, $before, "\e[1;30;43m", $hit, "\e[0m", $after, $suffix, "\n";
print "        ", (" " x length($prefix)), (" " x $hit_start), "\e[1;30;43m", ("^" x $hit_len), "\e[0m", "\n";
print "hit   > line $target_line, col $col\n";
'"'"' "$file" "$line" "$col" "$qlen"; printf "\n"; bat --paging=never --style=numbers --color=always --highlight-line "$line" --line-range "${line}::2" "$file"'

  fzf --ansi --disabled --query "$query" \
    --bind "start:reload:$reload_cmd" \
    --bind "change:reload:$reload_cmd" \
    --bind 'ctrl-v:transform:if [ "$FZF_PREVIEW_LABEL" = "Raw | Ctrl+V: format" ]; then printf "%s\n" "change-preview-label(Formatted | Ctrl+V: raw)+refresh-preview"; else printf "%s\n" "change-preview-label(Raw | Ctrl+V: format)+refresh-preview"; fi' \
    --delimiter : \
    --accept-nth 1,2,3 \
    --preview "$preview_cmd" \
    --preview-label 'Raw | Ctrl+V: format' \
    --preview-window "up,${preview_lines},<80(up)"
}



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

# pnpm
export PNPM_HOME="/Users/nb/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
