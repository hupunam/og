#!/bin/bash

prev_logSyncHeight=0
prev_time=$(date +%s)
sync_history=()
first_run=true

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

    eta_display=""

    # Determine status and ETA
    if [ "$diff" -ge 0 ]; then
        status="⚡ Ahead by $diff blocks"
        color="\033[36m"
        eta_display="🕒 ETA: Node is ahead"
    elif [ "$behind" -le 15 ]; then
        status="✅ Synced (≤15 blocks behind)"
        color="\033[32m"
        eta_display="🕒 ETA: Synced"
    else
        status="⏳ Behind by $behind blocks"
        color="\033[33m"
        
        # Always show ETA calculation status from first iteration
        if [ "$first_run" = true ]; then
            eta_display="🕒 ETA: Starting sync analysis..."
        elif [ "$elapsed" -eq 0 ] || [ "$blocks_synced" -le 0 ]; then
            eta_display="🕒 ETA: Waiting for sync progress..."
        else
            # Calculate current sync rate (blocks per second)
            current_rate=$(echo "scale=2; $blocks_synced / $elapsed" | bc)
            
            # Store sync rate for averaging (keep last 8 samples for 40-second window)
            sync_history+=($current_rate)
            if [ ${#sync_history[@]} -gt 8 ]; then
                sync_history=("${sync_history[@]:1}")
            fi
            
            # Calculate average sync rate from collected samples
            if [ ${#sync_history[@]} -ge 2 ]; then
                sum=0
                for rate in "${sync_history[@]}"; do
                    sum=$(echo "$sum + $rate" | bc)
                done
                avg_rate=$(echo "scale=2; $sum / ${#sync_history[@]}" | bc)
                
                # Only calculate ETA if we have meaningful sync rate
                if (( $(echo "$avg_rate > 0.1" | bc -l) )); then
                    eta_seconds=$(echo "scale=0; $behind / $avg_rate" | bc)
                    
                    # Format ETA based on duration
                    if [ "$eta_seconds" -lt 60 ]; then
                        eta_display="🕒 ETA: <1min (${avg_rate} bl/s)"
                    elif [ "$eta_seconds" -lt 3600 ]; then
                        eta_minutes=$((eta_seconds / 60))
                        eta_display="🕒 ETA: ${eta_minutes}min (${avg_rate} bl/s)"
                    elif [ "$eta_seconds" -lt 86400 ]; then
                        eta_hours=$((eta_seconds / 3600))
                        eta_minutes=$(((eta_seconds % 3600) / 60))
                        eta_display="🕒 ETA: ${eta_hours}h ${eta_minutes}min (${avg_rate} bl/s)"
                    else
                        eta_days=$((eta_seconds / 86400))
                        eta_hours=$(((eta_seconds % 86400) / 3600))
                        eta_display="🕒 ETA: ${eta_days}d ${eta_hours}h (${avg_rate} bl/s)"
                    fi
                else
                    eta_display="🕒 ETA: Very slow sync (${avg_rate} bl/s)"
                fi
            else
                eta_display="🕒 ETA: Collecting data... (${#sync_history[@]}/2 samples)"
            fi
        fi
    fi

    # Print result with enhanced colors and better formatting
    log_display="${logSyncHeight:-N/A}"
    remote_display="${remote_block:-N/A}"
    peers_display="${connectedPeers:-N/A}"
    
    # Use bright colors for better visibility
    echo -e "🧱 LOGS: \033[1;32m$log_display\033[0m | 🌐 CURRENT: \033[1;35m$remote_display\033[0m | 🤝 PEERS: \033[1;34m$peers_display\033[0m | STATUS: ${status_color}${status}\033[0m $eta_display"

    # Update previous values
    prev_logSyncHeight=${logSyncHeight:-$prev_logSyncHeight}
    prev_time=$current_time
    first_run=false

    sleep 5
done
