#!/bin/bash
# manage truecrypt containers using tcplay

user=nb
cryptdev=$(echo "$2" | awk -F/ '{print $NF}')
cryptpath="$2"
loopdev=$(losetup -f)
mountpt=/media/"$cryptdev"

# must be run as root
if [[ $EUID != 0 ]]; then
  printf "%s\n" "You must be root to run this."
  exit 1
fi

# unecrypt and mount container
if [[ "$1" == "open" ]]; then
  losetup "$loopdev" "$cryptpath"
  tcplay --map="$cryptdev" --device="$loopdev"

# read passphrase
  read -r -s passphrase <<EOF
  "$passphrase"
EOF

# mount container
  [[ -d "$mountpt" ]] || mkdir "$mountpt"

# mount options
  userid=$(awk -F"[=(]" '{print $2,$4}' <(id "$user"))
  mount -o nosuid,uid="${userid% *}",gid="${userid#* }" /dev/mapper/"$cryptdev" "$mountpt"

# close and clean up…
elif [[ "$1" == "close" ]]; then
  device=$(awk -v dev=$cryptdev -F":" '/dev/ {print $1}' <(losetup -a))
  umount "$mountpt"
  dmsetup remove "$cryptdev" || printf "%s\n" "demapping failed"
  losetup -d "$device" || printf "%s\n" "deleting $loopdev failed"
  rmdir $mountpt || printf "%s\n" "deleting $mountpt failed, folder not empty?"
else
  printf "%s\n" "Options are open or close."
fi
