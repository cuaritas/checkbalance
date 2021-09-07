#!/bin/bash

# Check Balance changes in your LND channels local balance
# By Cuaritas 2021
# MIT License

# Use as a systemd service for more usability

BALANCE_FILEPATH="/home/umbrel/.balance"
MACAROON_HEADER="Grpc-Metadata-macaroon: $(xxd -ps -u -c 1000 /home/umbrel/.lnd/admin.macaroon)"
WEBHOOK="https://xxxxxxxxxxxxxxx.m.pipedream.net"

while sleep 3600; do

commit=`curl -s -X GET --cacert /home/umbrel/.lnd/tls.cert --header "$MACAROON_HEADER" https://umbrel.local:8080/v1/channels | jq -r '.channels[].commit_fee' | awk '{sum+=$1} END {print sum}'`
local=`curl -s -X GET --cacert /home/umbrel/.lnd/tls.cert --header "$MACAROON_HEADER" https://umbrel.local:8080/v1/channels | jq -r '.channels[].local_balance' | awk '{sum+=$1} END {print sum}'`
balance=$((local+commit))

if ! [[ -f $BALANCE_FILEPATH ]]; then
  echo $balance > $BALANCE_FILEPATH
fi

cat $BALANCE_FILEPATH | grep -q $balance
if [[ $? -ne 0 ]]; then # send notification using Pipedream
  echo $balance > $BALANCE_FILEPATH
  curl -s -F "balance=$balance" $WEBHOOK
  echo
else
  echo "Node balance $balance has not changed"
fi

done&
