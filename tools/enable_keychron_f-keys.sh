#!/usr/bin/env bash

# enables using F1-F12 keys on keychron keyboards natively
# source: https://mikeshade.com/posts/keychron-linux-function-keys/

echo "options hid_apple fnmode=0" | sudo tee -a /etc/modprobe.d/hid_apple.conf

