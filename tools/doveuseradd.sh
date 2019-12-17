#!/bin/bash
 
USERSFILE=/etc/dovecot/users
POSTFIXVIRTUAL_MAILBOX=/etc/postfix/vmailbox
POSTFIXVIRTUAL=/etc/postfix/virtual
#POSTFIXVIRTUAL_DOMAINS=/etc/postfix/virtual_domains

function check_root() {
	if [ "$(id -u)" != "0" ]
	then
		echo '[ERROR] must be root to use this script!'
		exit 1
	fi
}

function validate_username() {
    username=$1
    echo $username| egrep -iq '([[:alnum:]_.]+@[[:alnum:]_]+?\.[[:alpha:].]{2,6})'; RC=$?
    if [ ${RC} -ne 0 ]
    then
        echo "Invalid username, please ensure user@domain.tld format ($RC)"
        exit 1
	fi
}
         
 
function get_username() {
    echo -n "Username <user@domain.com>: "
    read username
    validate_username ${username}
}
 
function get_password() {
    echo -n "Password: "
    read -r password1
    echo -n "Password (again): "
    read -r password2
 
    if [ "${password1}" != "${password2}" ]
    then
         echo "Passwords don't match, please try again"
         get_password
    fi
}
 
function gen_ssha512() {
    local password=$1
    doveadm pw -s SSHA512 -p "$password"
}

function gen_argon2id() {
    local password=$1
    doveadm pw -s ARGON2ID -p "$password"
}
 
function check_dovecot_user() {
    grep -iq $username $USERSFILE; RC=$?
    if [ "${RC}" -eq 0 ]
    then
        echo "User already exists in $USERSFILE"
        echo "Here was the computed string used:"
        echo "${username}:${password}"
        exit 1
    fi
}
 
function check_postfix_maps() {
    grep -iq $username $POSTFIXVIRTUAL_MAILBOX; RC=$?
    if [ "${RC}" -eq 0 ]
    then
        echo "User already exists in $POSTFIXVIRTUAL_MAILBOX, please check."
        echo "For reference, or manual editing here was the computed string to use"
        echo
        echo "${username} OK"
        echo
        echo "You will also need to run 'postmap $POSTFIXVIRTUAL_MAILBOX' if you edit this file directly"
        exit 1
    fi
}
 
function check_postfix_virtual() {
    grep -iq $username $POSTFIXVIRTUAL; RC=$?
    if [ "${RC}" -ne 0 ]
    then
		local usr=$(echo "$username" | cut -d@ -f1)
        echo "$username			${usr}" >> $POSTFIXVIRTUAL
    fi
}

check_root
get_username
get_password
# password=$(gen_ssha512)
password=$(gen_argon2id)
check_dovecot_user
check_postfix_maps

echo "Beginning to write stuff to disk, errors from here on require manual fixing"

check_postfix_virtual
 
echo "${username}:${password}" >> $USERSFILE
echo "${username}		OK" >> $POSTFIXVIRTUAL_MAILBOX
 
postmap $POSTFIXVIRTUAL_MAILBOX
postmap $POSTFIXVIRTUAL

systemctl restart postfix
 
echo "Done"
