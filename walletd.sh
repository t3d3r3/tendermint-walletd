#!/usr/bin/env bash
source ".env"

usage() {
    cat <<EOF
usage: ./${0##*/} wallet_from address_to

wallet_name
    wallet previously imported using
    "${EXEC_PATH:-}" keys add wallet_name --recover --keyring-backend=test

address_to
    address to sent the available amount to 

EOF
}


#need two args
if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

#check bin
cd ${EXEC_PATH}
VERSION="$(./${EXEC_BIN} version)"
echo "Found ${EXEC_BIN} version ${VERSION}"
#check key
FROM="$(./${EXEC_BIN} keys show $1 --keyring-backend=test --output=json | jq -r '.address')"
if [ "${FROM}" == "" ]; then
    echo "ERROR: invalid wallet_from"
    exit 1
fi
CHAIN_ID="$(curl -s ${RPC}/status | jq -r '.result.node_info.network')"
echo "Watching address ${FROM} on chain ${CHAIN_ID}"
DATE=$(date +%s)
while [ 1 ]
do
    #check balance
    BALANCE="$(./${EXEC_BIN} q bank balances ${FROM} --node=${RPC} --output=json | jq -c '.balances[] | select(.denom | contains("uluna"))' | jq '.amount | tonumber' )"
    CDATE=$(date +%s)
    if [ ${CDATE} -gt $((${DATE}+60)) ]; then
        echo "${CDATE}: Wallet balance ${BALANCE}"
        DATE=${CDATE}
    fi
    if [ ${BALANCE} -gt ${THRESHOLD} ]; then
        #transfer
        TX_AMOUNT=$((${BALANCE}-${FEES}*14/10))${DENOM}
        TX="$(./${EXEC_BIN} tx bank send $1 $2 ${TX_AMOUNT} --chain-id=${CHAIN_ID} --keyring-backend=test --gas=auto --fees=${FEES}${DENOM} --gas-adjustment=1.4 -y --node=${RPC})"
        echo "${CDATE}: Tranferred ${TX_AMOUNT} to $2"
        #wait a block
        sleep 10
    fi
done