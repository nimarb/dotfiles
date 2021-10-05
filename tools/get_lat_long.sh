#!/usr/bin/env bash

function get_lat_long() {
    output="48.14:11.58"
    ret_val=0
    if [[ ! $(curl -s --fail "ipinfo.io") ]]; then
        ret_val=1
    else
        output=$(curl -s ipinfo.io | jq -j .loc | tr ',' ':')
    fi
    if [[ $output =~ ^[0-9]{1,2}\.[0-9]{0,4}:[0-9]{1,2}\.[0-9]{0,4} ]]; then
        echo "$output"
        return $ret_val
    else
        echo "didn't match lat long regex, perhaps ipinfo.io curl error"
        return 1
    fi
}

get_lat_long
