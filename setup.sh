#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Graceful exit function
graceful_exit() {
    echo ""
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        👋 Thank You! 👋                          ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}🙏 Thank you for using Testnet Terminal's OneClick Setup!${NC}"
    echo ""
    echo -e "${YELLOW}🔗 Stay Connected:${NC}"
    echo -e "${BLUE}📱 Telegram: ${NC}https://t.me/TestnetTerminal"
    echo -e "${BLUE}🐙 GitHub: ${NC}https://github.com/TestnetTerminal" 
    echo -e "${BLUE}🐦 Twitter: ${NC}https://x.com/TestnetTerminal"
    echo -e "${BLUE}🆘 Support: ${NC}https://t.me/Amit3701"
    echo ""
    echo -e "${GREEN}✨ Happy Testing! See you next time! ✨${NC}"
    echo ""
    exit 0
}

# Set trap to catch Ctrl+C and other signals
trap 'graceful_exit' INT TERM

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${CYAN}[SUCCESS]${NC} $1"
}

# Display main banner
show_banner() {
    clear
    echo ""
    echo -e "${BLUE}████████╗███████╗███████╗████████╗███╗   ██╗███████╗████████╗    ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     ${NC}"
    echo -e "${BLUE}╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝████╗  ██║██╔════╝╚══██╔══╝    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     ${NC}"
    echo -e "${BLUE}   ██║   █████╗  ███████╗   ██║   ██╔██╗ ██║█████╗     ██║          ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     ${NC}"
    echo -e "${BLUE}   ██║   ██╔══╝  ╚════██║   ██║   ██║╚██╗██║██╔══╝     ██║          ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     ${NC}"
    echo -e "${BLUE}   ██║   ███████╗███████║   ██║   ██║ ╚████║███████╗   ██║          ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗${NC}"
    echo -e "${BLUE}   ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═══╝╚══════╝   ╚═╝          ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝${NC}"
    echo ""
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║            🎉 Thank you for using our One-Click Setup! 🎉       ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}🔗 Our Links:${NC}"
    echo -e "${YELLOW}📱 Telegram: ${NC}https://t.me/TestnetTerminal"
    echo -e "${YELLOW}🐙 GitHub: ${NC}https://github.com/TestnetTerminal"
    echo -e "${YELLOW}🐦 Twitter/X: ${NC}https://x.com/TestnetTerminal"
    echo -e "${YELLOW}🆘 Support: ${NC}https://t.me/Amit3701"
    echo ""
}

# Display menu
show_menu() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║             🚀 0G Storage Node OneClick Setup by Amit            ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Please select an option:${NC}"
    echo ""
    echo -e "${YELLOW}1. 🛠️  Install 0G Storage Node${NC}"
    echo -e "${RED}2. 🗑️  Stop & Delete 0G Storage Node${NC}"
    echo -e "${PURPLE}3. 📥 Download Snapshot (Faster Sync)${NC}"
    echo -e "${RED}4. ❌ Exit${NC}"
    echo ""
    echo -n -e "${WHITE}Select an option (1-4): ${NC}"
}

# Function to check current block sync status
check_block_sync() {
    local timeout=30
    local count=0
    
    print_status "🔍 Checking block sync status..."
    
    while [ $count -lt $timeout ]; do
        if response=$(curl -s -X POST http://localhost:5678 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}' 2>/dev/null); then
            if logSyncHeight=$(echo "$response" | jq -r '.result.logSyncHeight' 2>/dev/null) && [ "$logSyncHeight" != "null" ] && [ "$logSyncHeight" -gt 0 ] 2>/dev/null; then
                connectedPeers=$(echo "$response" | jq -r '.result.connectedPeers' 2>/dev/null)
                echo -e "${GREEN}✅ Node is syncing!${NC}"
                echo -e "${CYAN}📊 Current Block: ${NC}$logSyncHeight"
                echo -e "${CYAN}👥 Connected Peers: ${NC}$connectedPeers"
                return 0
            fi
        fi
        
        count=$((count + 1))
        echo -n "."
        sleep 1
    done
    
    echo -e "\n${YELLOW}⚠️ Unable to get sync status (node may still be starting)${NC}"
    return 1
}

# Function to monitor block sync with auto-stop
monitor_block_sync() {
    local target_block=${1:-5611223}
    local stop_monitoring=false
    
    echo -e "${CYAN}🔄 Monitoring block sync (will auto-stop at block $target_block)...${NC}"
    echo -e "${YELLOW}⚠️ Press Ctrl+C to stop monitoring manually${NC}"
    echo ""
    
    while [ "$stop_monitoring" = false ]; do
        if response=$(curl -s -X POST http://localhost:5678 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}' 2>/dev/null); then
            if logSyncHeight=$(echo "$response" | jq -r '.result.logSyncHeight' 2>/dev/null) && [ "$logSyncHeight" != "null" ] && [ "$logSyncHeight" -gt 0 ] 2>/dev/null; then
                connectedPeers=$(echo "$response" | jq -r '.result.connectedPeers' 2>/dev/null)
                echo -e "\r${CYAN}📊 Block: ${NC}$logSyncHeight ${CYAN}| Peers: ${NC}$connectedPeers                    "
                
                # Check if we've reached the target block
                if [ "$logSyncHeight" -ge "$target_block" ]; then
                    echo ""
                    print_success "🎉 Reached block $target_block! Stopping monitoring..."
                    stop_monitoring=true
                fi
            else
                echo -e "\r${YELLOW}⚠️ Waiting for sync to start...                    "
            fi
        else
            echo -e "\r${RED}❌ Cannot connect to node API...                    "
        fi
        
        sleep 5
    done
}

# Install 0G Storage Node
install_og_storage_node() {
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                  🛠️ Installing 0G Storage Node 🛠️               ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check if node already exists
    if [ -d "$HOME/0g-storage-node" ]; then
        print_warning "⚠️ 0G Storage Node directory already exists!"
        echo ""
        echo -n -e "${WHITE}Do you want to continue and overwrite? (y/N): ${NC}"
        read -r overwrite_confirm
        case "${overwrite_confirm,,}" in
            y|yes)
                print_status "🔄 Removing existing installation..."
                sudo systemctl stop zgs 2>/dev/null || true
                sudo systemctl disable zgs 2>/dev/null || true
                sudo rm -f /etc/systemd/system/zgs.service 2>/dev/null || true
                rm -rf "$HOME/0g-storage-node"
                print_success "✅ Existing installation removed"
                ;;
            *)
                print_status "❌ Installation cancelled by user"
                read -p "Press Enter to return to main menu..."
                return
                ;;
        esac
    fi

    print_status "📦 Updating system and installing dependencies..."
    sudo apt-get update && sudo apt-get upgrade -y

    print_status "📦 Installing required packages..."
    sudo apt install curl iptables build-essential git wget lz4 jq make protobuf-compiler cmake gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev screen ufw -y

    # Install Rust
    if ! command -v rustc &>/dev/null; then
        print_status "🦀 Installing Rustup..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        print_success "✅ Rust is already installed ($(rustc --version))"
        source "$HOME/.cargo/env" 2>/dev/null || true
    fi

    # Install Go
    if ! command -v go &>/dev/null; then
        print_status "🐹 Installing Go..."
        wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
        rm go1.24.3.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        export PATH=$PATH:/usr/local/go/bin
    else
        print_success "✅ Go is already installed ($(go version))"
    fi

    print_status "📁 Cloning 0G Storage Node repository..."
    git clone https://github.com/0glabs/0g-storage-node.git
    cd "$HOME/0g-storage-node"
    git checkout v1.1.0
    git submodule update --init

    print_status "🔨 Building in release mode (this may take several minutes)..."
    cargo build --release

    print_status "⚙️ Setting up configuration..."
    rm -rf "$HOME/0g-storage-node/run/config.toml"
    curl -o "$HOME/0g-storage-node/run/config.toml" https://raw.githubusercontent.com/Mayankgg01/0G-Storage-Node-Guide/main/config.toml

    # Get private key from user
    echo ""
    echo -e "${YELLOW}🔑 Private Key Configuration${NC}"
    echo -e "${CYAN}Please enter your wallet's private key:${NC}"
    echo -e "${RED}⚠️ Do NOT include '0x' prefix${NC}"
    echo -e "${YELLOW}💡 Your private key will be securely added to config.toml${NC}"
    echo ""
    echo -n -e "${WHITE}Enter Private Key: ${NC}"
    read -r -s PRIVATE_KEY
    echo ""
    
    if [ -z "$PRIVATE_KEY" ]; then
        print_error "❌ Private key cannot be empty!"
        read -p "Press Enter to return to main menu..."
        return
    fi

    # Remove 0x prefix if present
    PRIVATE_KEY=$(echo "$PRIVATE_KEY" | sed 's/^0x//')

    # Update config.toml with private key
    sed -i "s/miner_key = \"\"/miner_key = \"$PRIVATE_KEY\"/" "$HOME/0g-storage-node/run/config.toml"
    print_success "✅ Private key successfully added to config.toml"

    # Ask about RPC endpoint
    echo ""
    echo -e "${YELLOW}🌐 RPC Endpoint Configuration${NC}"
    echo -e "${CYAN}Do you want to use a custom RPC endpoint?${NC}"
    echo -e "${GREEN}Press Enter or 'y' to use official RPC${NC}"
    echo -e "${YELLOW}Enter custom RPC URL to use custom endpoint${NC}"
    echo ""
    echo -n -e "${WHITE}RPC Endpoint (or press Enter for official): ${NC}"
    read -r RPC_ENDPOINT

    if [ -n "$RPC_ENDPOINT" ] && [ "$RPC_ENDPOINT" != "y" ] && [ "$RPC_ENDPOINT" != "Y" ]; then
        # Update config with custom RPC
        sed -i "s|blockchain_rpc_endpoint = \".*\"|blockchain_rpc_endpoint = \"$RPC_ENDPOINT\"|" "$HOME/0g-storage-node/run/config.toml"
        print_success "✅ Custom RPC endpoint configured: $RPC_ENDPOINT"
    else
        print_success "✅ Using official RPC endpoint"
    fi

    print_status "⚙️ Creating systemd service..."
    sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=ZGS Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable zgs

    print_status "🚀 Starting 0G Storage Node..."
    sudo systemctl start zgs

    print_success "✅ 0G Storage Node service started!"
    echo ""
    print_status "⏳ Waiting 5 seconds for node to initialize..."
    sleep 5

    # Check if sync started
    if check_block_sync; then
        echo ""
        echo -e "${YELLOW}📥 Snapshot Download Option${NC}"
        echo -e "${CYAN}Your node is syncing from block 0. This may take several days.${NC}"
        echo -e "${GREEN}We recommend downloading a snapshot for faster sync!${NC}"
        echo ""
        echo -e "${YELLOW}Choose an option:${NC}"
        echo -e "${GREEN}A) Download snapshot (recommended - starts from block 5,611,223)${NC}"
        echo -e "${BLUE}B) Continue from scratch (slower but complete sync)${NC}"
        echo ""
        echo -n -e "${WHITE}Your choice (A/B): ${NC}"
        read -r snapshot_choice

        case "${snapshot_choice,,}" in
            a|"")
                download_snapshot
                ;;
            b)
                print_status "✅ Continuing with full sync from genesis block"
                echo ""
                print_success "🎉 0G Storage Node successfully installed and running!"
                ;;
        esac
    else
        print_warning "⚠️ Node may still be starting up. Please check manually later."
    fi

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 Installation Complete! 🎉                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📋 Useful Commands:${NC}"
    echo -e "${YELLOW}sudo systemctl status zgs${NC}          # Check service status"
    echo -e "${YELLOW}sudo systemctl restart zgs${NC}         # Restart service"
    echo -e "${YELLOW}tail -f ~/0g-storage-node/run/log/zgs.log.\$(TZ=UTC date +%Y-%m-%d)${NC}  # View logs"
    echo ""
    echo -e "${PURPLE}🤖 Get Transaction & Reward Notifications:${NC}"
    echo -e "${BLUE}📱 Telegram Bot: ${NC}https://t.me/og_tracker_bot"
    echo ""
    echo -e "${GREEN}✨ Thank you for using Testnet Terminal's OneClick Setup! ✨${NC}"
    echo ""

    read -p "Press Enter to return to main menu..."
}

# Stop and Delete 0G Storage Node
delete_og_storage_node() {
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                  🗑️ Delete 0G Storage Node 🗑️                   ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_warning "⚠️ This will completely remove 0G Storage Node from your system!"
    echo ""
    echo -e "${YELLOW}📋 What will be deleted:${NC}"
    echo "• 0g-storage-node directory and all contents"
    echo "• ZGS systemd service"
    echo "• All synced blockchain data"
    echo "• Configuration files"
    echo ""
    
    echo -n -e "${WHITE}❓ Are you sure you want to delete 0G Storage Node? (y/N): ${NC}"
    read -r delete_confirm
    
    case "${delete_confirm,,}" in
        y|yes)
            ;;
        *)
            print_status "✅ Deletion cancelled. Your 0G Storage Node is safe!"
            echo ""
            read -p "Press Enter to return to main menu..."
            return
            ;;
    esac
    
    echo ""
    print_status "🗑️ Starting deletion process..."
    
    # Stop service
    if systemctl is-active --quiet zgs 2>/dev/null; then
        print_status "🔄 Stopping ZGS service..."
        sudo systemctl stop zgs
        print_success "✅ Service stopped"
    fi
    
    # Disable and remove service
    if systemctl is-enabled --quiet zgs 2>/dev/null; then
        print_status "🔄 Disabling ZGS service..."
        sudo systemctl disable zgs
    fi
    
    if [ -f "/etc/systemd/system/zgs.service" ]; then
        print_status "🗑️ Removing service file..."
        sudo rm /etc/systemd/system/zgs.service
        sudo systemctl daemon-reload
        print_success "✅ Service file removed"
    fi
    
    # Remove directory
    if [ -d "$HOME/0g-storage-node" ]; then
        print_status "📁 Removing 0g-storage-node directory..."
        rm -rf "$HOME/0g-storage-node"
        print_success "✅ Directory removed"
    fi
    
    echo ""
    print_success "✅ 0G Storage Node completely removed!"
    echo ""
    echo -e "${GREEN}💡 You can reinstall anytime using option 1${NC}"
    echo ""
    
    read -p "Press Enter to return to main menu..."
}

# Download Snapshot
download_snapshot() {
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                   📥 Download Snapshot 📥                       ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check if node exists and is running
    if [ ! -d "$HOME/0g-storage-node" ]; then
        print_error "❌ 0G Storage Node not found!"
        echo ""
        print_status "💡 Please install the node first using option 1"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi

    # Check current sync status
    print_status "🔍 Checking current sync status..."
    
    if response=$(curl -s -X POST http://localhost:5678 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}' 2>/dev/null); then
        if logSyncHeight=$(echo "$response" | jq -r '.result.logSyncHeight' 2>/dev/null) && [ "$logSyncHeight" != "null" ] && [ "$logSyncHeight" -gt 0 ] 2>/dev/null; then
            echo -e "${CYAN}📊 Current sync block: ${NC}$logSyncHeight"
            
            # Check if already past snapshot block
            if [ "$logSyncHeight" -gt 4000000 ]; then
                echo ""
                print_warning "⚠️ Your node has already synced to block $logSyncHeight"
                echo -e "${YELLOW}The snapshot starts from block 5,611,223${NC}"
                echo -e "${CYAN}In 1-2 days, you'll naturally reach that block anyway.${NC}"
                echo ""
                echo -n -e "${WHITE}Are you sure you want to delete current progress and use snapshot? (y/N): ${NC}"
                read -r snapshot_confirm
                case "${snapshot_confirm,,}" in
                    y|yes)
                        ;;
                    *)
                        print_status "✅ Snapshot download cancelled. Keeping current progress."
                        echo ""
                        read -p "Press Enter to return to main menu..."
                        return
                        ;;
                esac
            fi
        fi
    fi

    print_status "⏸️ Stopping ZGS service..."
    sudo systemctl stop zgs
    sleep 3

    print_status "🗑️ Removing current flow_db..."
    rm -rf "$HOME/0g-storage-node/run/db/flow_db"

    print_status "📁 Creating snapshots directory..."
    mkdir -p "$HOME/snapshots"
    cd "$HOME/snapshots"

    print_status "📥 Downloading snapshot parts (this may take a while)..."
    echo -e "${CYAN}📊 Snapshot info: Block 5,611,223 | Size: ~several GB${NC}"
    
    # Download first part
    print_status "📥 Downloading part 1/2..."
    if ! wget -q --show-progress https://github.com/amibunny/0g-storage-node-guide/releases/download/snapshot-block-5611223/flow_db.part-aa; then
        print_error "❌ Failed to download snapshot part 1"
        print_status "🔄 Restarting ZGS service..."
        sudo systemctl start zgs
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    # Download second part
    print_status "📥 Downloading part 2/2..."
    if ! wget -q --show-progress https://github.com/amibunny/0g-storage-node-guide/releases/download/snapshot-block-5611223/flow_db.part-ab; then
        print_error "❌ Failed to download snapshot part 2"
        print_status "🔄 Restarting ZGS service..."
        sudo systemctl start zgs
        read -p "Press Enter to return to main menu..."
        return
    fi

    print_status "🔗 Combining snapshot parts..."
    cat flow_db.part-* > flow_db.tar.xz

    print_status "📦 Extracting snapshot..."
    tar -xJvf flow_db.tar.xz -C "$HOME/0g-storage-node/run/db/"

    print_status "🚀 Restarting ZGS service..."
    sudo systemctl restart zgs

    print_success "✅ Snapshot download and extraction completed!"
    echo ""
    print_status "⏳ Waiting 5 seconds for service to start..."
    sleep 5

    # Monitor sync and auto-stop when reached snapshot block
    if check_block_sync; then
        echo ""
        monitor_block_sync 5611223
        
        echo ""
        print_success "🎉 Snapshot installation completed successfully!"
        echo ""
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                      🎊 All Done! 🎊                            ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}✅ Your 0G Storage Node is now running from block 5,611,223!${NC}"
        echo ""
        echo -e "${PURPLE}🤖 Get Transaction & Reward Notifications:${NC}"
        echo -e "${BLUE}📱 Telegram Bot: ${NC}https://t.me/og_tracker_bot"
        echo ""
        echo -e "${GREEN}🙏 Thank you for using Testnet Terminal's OneClick Setup!${NC}"
        echo ""
        
        # Auto exit after successful completion
        echo -e "${YELLOW}⏰ Exiting in 10 seconds...${NC}"
        for i in {10..1}; do
            echo -ne "\r${CYAN}Exiting in $i seconds... ${NC}"
            sleep 1
        done
        echo ""
        graceful_exit
    else
        print_warning "⚠️ Could not verify sync status. Please check manually."
    fi

    # Clean up
    print_status "🧹 Cleaning up snapshot files..."
    rm -rf "$HOME/snapshots"

    echo ""
    read -p "Press Enter to return to main menu..."
}

# Exit function
exit_script() {
    graceful_exit
}

# Main menu loop
main() {
    while true; do
        show_banner
        show_menu
        
        read -r choice
        
        case $choice in
            1)
                install_og_storage_node
                ;;
            2)
                delete_og_storage_node
                ;;
            3)
                download_snapshot
                ;;
            4)
                exit_script
                ;;
            *)
                echo ""
                print_error "❌ Invalid option. Please select 1-4."
                echo ""
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Initialize and run
main "$@"
