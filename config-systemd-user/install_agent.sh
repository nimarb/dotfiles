#!/usr/bin/env bash

mkdir -p ~/.config/systemd/user
cp ssh-agent.service ~/.config/systemd/user/ssh-agent.service
systemctl --user start ssh-agent.service
systemctl --user enable ssh-agent.service
systemctl --user status ssh-agent.service

