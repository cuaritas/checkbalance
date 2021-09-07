#!/bin/bash

# Check Balance changes in your LND channels local balance
# By Cuaritas 2021
# MIT License

# Use as a systemd service for more usability

BALANCE_FILEPATH="$HOME/.balance"
LNCLI="/usr/bin/lncli"
WEBHOOK="https://xxxxxxxxxxxxxxxxxx.m.pipedream.net"
balance=`$LNCLI channelbalance | jq .balance`

if ! [[ -f $BALANCE_FILEPATH ]]; then
  echo $balance > $BALANCE_FILEPATH
fi

cat $BALANCE_FILEPATH | grep -q $balance
if [[ $? -ne 0 ]]; then # send notification using Pipedream
  curl -s -d "{balance:$balance}" -H "Content-Type: text/plain" $WEBHOOK
fi
