#!/bin/bash
# NETWORK TOOLKIT - Linux Version

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Functions
print_menu() { echo -e "${CYAN}\n===== NETWORK TOOLKIT =====\n${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; }

# ============ TOOL 1: WiFi Password Manager ============
show_wifi_passwords() {
    echo -e "\n${MAGENTA}📶 SAVED WIFI NETWORKS:\n${NC}"
    
    # Find saved connections
    if [ -d /etc/NetworkManager/system-connections ]; then
        sudo ls /etc/NetworkManager/system-connections/ 2>/dev/null | while read conn; do
            if [ -f "/etc/NetworkManager/system-connections/$conn" ]; then
                echo -e "${GREEN}  $conn${NC}"
                password=$(sudo grep -i "psk=" "/etc/NetworkManager/system-connections/$conn" 2>/dev/null | cut -d'=' -f2)
                if [ ! -z "$password" ]; then
                    echo -e "    Password: ${password}${NC}"
                fi
            fi
        done
    else
        print_info "Showing saved WiFi networks (requires nmcli)"
        nmcli dev wifi show-password 2>/dev/null || print_error "Run with sudo or install nmcli"
    fi
    
    # Backup option
    read -p "Backup passwords to file? (y/n): " backup
    if [ "$backup" = "y" ]; then
        date=$(date +%Y-%m-%d_%H-%M)
        filename="wifi_backup_$date.txt"
        sudo bash -c "nmcli dev wifi show-password > $filename" 2>/dev/null
        print_success "Saved to $filename"
    fi
}

# ============ TOOL 2: Network Speed Tester ============
test_speed() {
    echo -e "\n${MAGENTA}📊 TESTING NETWORK SPEED...\n${NC}"
    
    # Use curl to download test file
    print_info "Download test..."
    start_time=$(date +%s.%N)
    curl -o /dev/null -s http://speedtest.tele2.net/50MB.zip
    end_time=$(date +%s.%N)
    
    duration=$(echo "$end_time - $start_time" | bc)
    speed_mbps=$(echo "scale=2; (50 * 8) / $duration" | bc)
    
    # Ping test
    ping_time=$(ping -c 4 google.com | tail -1 | awk '{print $4}' | cut -d'/' -f2)
    
    echo -e "\n${CYAN}📈 RESULTS:${NC}"
    echo "  Download Speed: ${speed_mbps} Mbps"
    echo "  Latency (Ping): ${ping_time} ms"
    echo "  Test Time: $(date +%H:%M:%S)"
    
    if (( $(echo "$speed_mbps > 50" | bc -l) )); then
        echo -e "  Rating: ${GREEN}🚀 Excellent${NC}"
    elif (( $(echo "$speed_mbps > 20" | bc -l) )); then
        echo -e "  Rating: ${YELLOW}👍 Good${NC}"
    else
        echo -e "  Rating: ${RED}⚠️ Slow${NC}"
    fi
}

# ============ TOOL 3: LAN File Share ============
start_lan_share() {
    echo -e "\n${MAGENTA}📁 LAN FILE SHARE\n${NC}"
    
    read -p "Enter full path to file or folder: " filepath
    
    if [ ! -e "$filepath" ]; then
        print_error "Path not found!"
        return
    fi
    
    # Get local IP
    local_ip=$(hostname -I | awk '{print $1}')
    
    print_info "Starting file server..."
    echo -e "\n${CYAN}📤 SHARE THIS LINK:${NC}"
    echo -e "${GREEN}  http://${local_ip}:8080${NC}"
    echo -e "\n${YELLOW}⚠️  Press Ctrl+C to stop sharing${NC}"
    
    # Start Python HTTP server
    cd "$(dirname "$filepath")"
    python3 -m http.server 8080 || print_error "Python3 required. Install with: sudo apt install python3"
}

# ============ TOOL 4: IP Scanner ============
scan_network() {
    echo -e "\n${MAGENTA}🌐 SCANNING NETWORK FOR DEVICES...\n${NC}"
    
    # Get subnet
    local_ip=$(hostname -I | awk '{print $1}')
    subnet=$(echo $local_ip | cut -d. -f1-3)
    
    print_info "Scanning ${subnet}.1-254..."
    echo -e "\n${CYAN}Active devices:${NC}\n"
    
    # Ping scan
    for i in {1..30}; do
        ip="${subnet}.${i}"
        if ping -c 1 -W 1 $ip > /dev/null 2>&1; then
            hostname=$(nslookup $ip 2>/dev/null | grep "name =" | awk '{print $4}' | sed 's/\.$//')
            if [ -z "$hostname" ]; then
                hostname="Unknown"
            fi
            echo -e "  ${GREEN}✓ $ip${NC}"
            echo -e "    → $hostname"
            ((count++))
        fi
        
        if [ $((i % 10)) -eq 0 ]; then
            print_info "Scanned $i/30..."
        fi
    done
    
    echo -e "\n${GREEN}✅ Found $count active devices${NC}"
    
    # Full scan option
    read -p "Scan all 254 IPs? (y/n - may take 2-3 minutes): " fullscan
    if [ "$fullscan" = "y" ]; then
        print_info "Full scan in progress..."
        for i in {31..254}; do
            ip="${subnet}.${i}"
            if ping -c 1 -W 1 $ip > /dev/null 2>&1; then
                echo -e "  ${GREEN}✓ $ip${NC}"
                ((count++))
            fi
            if [ $((i % 50)) -eq 0 ]; then
                print_info "Scanned $i/254..."
            fi
        done
        print_success "Full scan complete. Total devices: $count"
    fi
}

# ============ TOOL 5: Network Usage Monitor ============
watch_bandwidth() {
    echo -e "\n${MAGENTA}📈 NETWORK USAGE MONITOR (Press Ctrl+C to stop)\n${NC}"
    echo -e "${CYAN}Top bandwidth processes:${NC}\n"
    
    # Show netstat connections
    while true; do
        clear
        echo -e "${MAGENTA}Network Connections:${NC}\n"
        sudo netstat -tunap 2>/dev/null | grep ESTABLISHED | awk '{print $7}' | cut -d'/' -f2 | sort | uniq -c | sort -rn | head -10 | while read count proc; do
            if [ ! -z "$proc" ]; then
                echo -e "  ${GREEN}$proc${NC} - $count connections"
            fi
        done
        echo -e "\n${YELLOW}Press Ctrl+C to return to menu${NC}"
        sleep 3
    done
}

# ============ MAIN MENU ============
# Create Linux Version (Bash)
while true; do
    clear
    print_menu
    echo " 1. 📶 WiFi Password Manager (view & backup)"
    echo " 2. 📊 Network Speed Tester"
    echo " 3. 📁 LAN File Share (P2P transfer)"
    echo " 4. 🌐 IP Scanner (find devices on network)"
    echo " 5. 📈 Network Usage Monitor"
    echo -e " 6. 🚪 Exit\n"
    
    read -p "Choose option (1-6): " choice
    
    case $choice in
        1) show_wifi_passwords; read -p "Press Enter to continue" ;;
        2) test_speed; read -p "Press Enter to continue" ;;
        3) start_lan_share; read -p "Press Enter to continue" ;;
        4) scan_network; read -p "Press Enter to continue" ;;
        5) watch_bandwidth ;;
        6) echo -e "\n${CYAN}👋 Goodbye!${NC}"; exit 0 ;;
        *) print_error "Invalid option"; sleep 1 ;;
    esac
done
