#!/bin/bash

prev_logSyncHeight=0
prev_time=$(date +%s)
sync_history=()  # Array to store recent sync rates for averaging

while true; do
    # Local node request
    local_response=$(curl -s -X POST http://localhost:5678 \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}')

    logSyncHeight=$(echo "$local_response" | grep -o '"logSyncHeight":[0-9]*' | cut -d':' -f2)
    connectedPeers=$(echo "$local_response" | grep -o '"connectedPeers":[0-9]*' | cut -d':' -f2)

    # External block number request using official RPC
    remote_response=$(curl -s -X POST https://evmrpc-testnet.0g.ai \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')
    
    # Extract hex block number and convert to decimal
    remote_block_hex=$(echo "$remote_response" | grep -o '"result":"0x[0-9a-fA-F]*"' | cut -d'"' -f4)
    remote_block=$((remote_block_hex))

    # Calculate differences
    diff=$((logSyncHeight - remote_block))
    behind=$((remote_block - logSyncHeight))

    # Time tracking
    current_time=$(date +%s)
    elapsed=$((current_time - prev_time))
    blocks_synced=$((logSyncHeight - prev_logSyncHeight))

    # Calculate sync rate with improved averaging
    sync_rate=0
    if [ "$elapsed" -gt 0 ] && [ "$blocks_synced" -gt 0 ]; then
        current_rate=$(echo "scale=4; $blocks_synced / $elapsed" | bc)
        sync_history+=($current_rate)
        
        # Keep only last 5 measurements for moving average (more responsive)
        if [ ${#sync_history[@]} -gt 5 ]; then
            sync_history=("${sync_history[@]:1}")
        fi
        
        # Calculate average sync rate
        if [ ${#sync_history[@]} -gt 0 ]; then
            sum=0
            for rate in "${sync_history[@]}"; do
                sum=$(echo "$sum + $rate" | bc)
            done
            sync_rate=$(echo "scale=4; $sum / ${#sync_history[@]}" | bc)
        fi
    fi

    eta_display=""

    # Determine status and ETA
    if [ "$diff" -ge 0 ]; then
        status="⚡ Ahead by $diff blocks"
        color="\033[36m"
        sync_history=()  # Reset history when ahead
    elif [ "$behind" -le 15 ]; then
        status="✅ Synced (≤15 blocks behind)"
        color="\033[32m"
        sync_history=()  # Reset history when synced
    else
        status="⏳ Behind by $behind blocks"
        color="\033[33m"
        
        # Only show ETA if we have reliable sync rate data and are significantly behind
        if [ ${#sync_history[@]} -ge 3 ] && (( $(echo "$sync_rate > 0.01" | bc -l) )) && [ "$behind" -gt 50 ]; then
            eta_seconds=$(echo "scale=0; $behind / $sync_rate" | bc)
            
            # Only show reasonable ETAs (between 1 minute and 24 hours)
            if [ "$eta_seconds" -ge 60 ] && [ "$eta_seconds" -le 86400 ]; then
                eta_hours=$((eta_seconds / 3600))
                eta_minutes=$(((eta_seconds % 3600) / 60))
                eta_secs=$((eta_seconds % 60))
                eta_formatted=$(printf "%02d:%02d:%02d" $eta_hours $eta_minutes $eta_secs)
                eta_display="🕒 ETA: $eta_formatted (${sync_rate} bl/s)"
            fi
        fi
    fi

    # Print result with fallback for missing values
    log_display="${logSyncHeight:-N/A}"
    remote_display="${remote_block:-N/A}"
    peers_display="${connectedPeers:-N/A}"
    
    echo -e "🧱 LOGS: \033[32m$log_display\033[0m | 🌐 CURRENT: \033[35m$remote_display\033[0m | 🤝 PEERS: \033[34m$peers_display\033[0m | STATUS: ${color}${status}\033[0m $eta_display"

    # Update previous values
    prev_logSyncHeight=${logSyncHeight:-$prev_logSyncHeight}
    prev_time=$current_time

    sleep 5
done
