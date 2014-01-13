#!/bin/bash

# script to delete a user from a dovecot and postfix file using pwdfiles. 
# http://github.com/likyng/dotfiles 

USERSFILE=/etc/dovecot/users
POSTFIXVIRTUAL_MAILBOX=/etc/postfix/vmailbox
POSTFIXVIRTUAL=/etc/postfix/virtual

function check_root() {
	if [ "$(id -u)" != "0" ]
	then
		echo '[ERROR] must be root to use this script!'
		exit 1
	fi
}

function get_username() {
    echo -n "Username <user@domain.com>: "
    read username
    validate_username ${username}
}

function verify_delete() {
	read -p "Really delete EMail user $username ?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		echo "Aborting... No files have been changed!"
		exit 1
	fi
}

function delete_user() {

}

function restart_services() {
	postmap $POSTFIXVIRTUAL
	postmap $POSTFIXVIRTUAL_MAILBOX
	systemctl restart dovecot
	systemctl restart postfix
}

# executing functions with descriptive text... 
echo "Script to DELETE usernames from dovecot"
check_root
get_username
verify_delete
echo "Beginning to delete stuff from disk, errors from here on require manual fixing"
delete_user
restart_services

# END
