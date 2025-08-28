#!/bin/bash

while true; do
    # Get local node status
    local_response=$(curl -s -X POST http://localhost:5678 -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}')
    
    logSyncHeight=$(echo "$local_response" | jq '.result.logSyncHeight')
    connectedPeers=$(echo "$local_response" | jq '.result.connectedPeers')

    # Get remote block number
    remote_response=$(curl -s https://chainscan-galileo.0g.ai/v1/homeDashboard)
    remote_block=$(echo "$remote_response" | jq '.result.blockNumber')

    # Calculate difference
    diff=$((logSyncHeight - remote_block))

    # Status Message
    if [ "$diff" -eq 0 ]; then
        status="✅ Synced"
        color="\033[32m"
    elif [ "$diff" -lt 0 ]; then
        status="⏳ Behind by $((-diff)) blocks"
        color="\033[33m"
    else
        status="⚡ Ahead by $diff blocks"
        color="\033[36m"
    fi

    # Output with colors
    echo -e "LOGS: \033[32m$logSyncHeight\033[0m | CURRENT BLOCK: \033[35m$remote_block\033[0m | PEERS: \033[34m$connectedPeers\033[0m | STATUS: ${color}${status}\033[0m"

    sleep 5
done
