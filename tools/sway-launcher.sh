#!/bin/sh
# terminal application launcher for sway, using fzf
# source: https://gitlab.com/FlyingWombat/my-scripts/blob/master/sway-launcher
# Based on: https://github.com/swaywm/sway/issues/1367 
# original command:
# bindsym $altkey+space exec termite --name=launcher -e \
#    "bash -c 'compgen -c | sort -u | fzf --no-extended --print-query | \
#    tail -n1 | xargs -r swaymsg -t command exec'"

HIST_FILE="$HOME/.cache/sway-launcher-history.txt"

# Get shell command list
command_list=$(compgen -c | sort -u)

# read existing command history
if [ -f "$HIST_FILE" ]; then
    command_history=$(cat "$HIST_FILE")
else
    command_history=""
fi

# search command list
command_str=$(echo -e "${command_history}\n${command_list}" | \
    sed -E 's/^[0-9]+ (.+)$/\1/' | \
    fzf --no-extended --print-query --no-sort | \
    tail -n1) || exit 1

if [ "$command_str" == "" ]; then
    exit 1
fi
# echo "Command: $command_str"

# get full line from history (with count number)
hist_line=$(echo "$command_history" | grep --fixed-strings "$command_str")
# echo "Hist Line: $hist_line"

if [ "$hist_line" == "" ]; then
    hist_count=1
else
    # Increment usage count
    hist_count=$(echo "$hist_line" | sed -E 's/^([0-9]+) .+$/\1/')
    ((hist_count++))
    # delete line, to add updated later
    # echo "Hist Before: $command_history"
    command_history=$(echo "$command_history" | \
	grep --fixed-strings --invert-match "$command_str")
    # echo "Hist After: $command_history"
fi

# update history
update_line="${hist_count} ${command_str}"
echo -e "${update_line}\n${command_history}" | \
    sort --numeric-sort --reverse > "$HIST_FILE"
# echo "$update_line"

# execute command
echo "$command_str"
swaymsg -t command exec "$command_str"

