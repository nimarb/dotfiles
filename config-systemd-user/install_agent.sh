#!/usr/bin/env bash

cp ssh-agent.service ~/.config/systemd/user/ssh-agent.service
systemctl --user start ssh-agent.service
systemctl --user enable ssh-agent.service
