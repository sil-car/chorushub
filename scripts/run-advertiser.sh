#!/usr/bin/env bash

myip=$(ip -br a | grep UP | awk '{print $3}' | awk -F'/' '{print $1}')

chport=5913
data="ChorusHubInfo?version=3&address=${myip}&port=${chport}&hostname=$(hostname)"

bcip='255.255.255.255'
port='5911'

while true; do
    date
    echo -n "$data" | nc -4bu -w0 "$bcip" "$port"
    sleep 3
done
