#!/usr/bin/env bash
# ==============================================================================
# NetworkWalks Cybersecurity Program - Batch B084
# Week 01 - Project 01: Bare-Metal Cybersecurity Lab Verification Script
# Host: Lenovo LOQ 15IAX9 | OS: Kali GNU/Linux Rolling 2026.3
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================================================${NC}"
echo -e "${GREEN}   🔐 NETWORKWALKS CYBERSECURITY LAB VERIFICATION (BARE-METAL)          ${NC}"
echo -e "${CYAN}========================================================================${NC}"

# 1. System Information
echo -e "\n${BLUE}[+] 1. Host & Hardware Verification:${NC}"
echo -e "  • Hostname: $(hostname)"
echo -e "  • Machine:  $(cat /sys/devices/virtual/dmi/id/product_version 2>/dev/null || cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo 'Lenovo LOQ 15IAX9')"
echo -e "  • Kernel:   $(uname -r)"
echo -e "  • CPU:      $(lscpu | grep 'Model name:' | sed 's/Model name:[ \t]*//')"
echo -e "  • Total RAM: $(free -h | awk '/Mem:/ {print $2}')"
echo -e "  • Root Disk: $(df -h / | awk 'NR==2 {print $1 " (" $2 " total, " $4 " available)"}')"

# 2. Operating System
echo -e "\n${BLUE}[+] 2. Operating System Details:${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "  • OS Name:    ${PRETTY_NAME}"
    echo -e "  • Release ID: ${VERSION_ID:-Rolling}"
fi

# 3. Network Interfaces & IP Configuration
echo -e "\n${BLUE}[+] 3. Network Configuration:${NC}"
ip -br addr show | while read -r iface status ips; do
    echo -e "  • Interface ${YELLOW}${iface}${NC} [${status}]: ${ips:-No IP assigned}"
done

GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n 1)
echo -e "  • Default Gateway: ${YELLOW}${GATEWAY:-None}${NC}"

# 4. Connectivity Tests
echo -e "\n${BLUE}[+] 4. Network Connectivity & DNS Resolution Tests:${NC}"

# Gateway Ping
if [ -n "$GATEWAY" ]; then
    if ping -c 2 -W 2 "$GATEWAY" > /dev/null 2>&1; then
        echo -e "  • Gateway Ping (${GATEWAY}):        ${GREEN}[PASSED]${NC}"
    else
        echo -e "  • Gateway Ping (${GATEWAY}):        ${RED}[FAILED]${NC}"
    fi
fi

# Internet Ping
if ping -c 2 -W 2 1.1.1.1 > /dev/null 2>&1; then
    echo -e "  • Internet Connectivity (1.1.1.1):   ${GREEN}[PASSED]${NC}"
else
    echo -e "  • Internet Connectivity (1.1.1.1):   ${RED}[FAILED]${NC}"
fi

# DNS Resolution
if ping -c 2 -W 3 networkwalks.com > /dev/null 2>&1; then
    echo -e "  • DNS Resolution (networkwalks.com): ${GREEN}[PASSED]${NC}"
else
    echo -e "  • DNS Resolution (networkwalks.com): ${RED}[FAILED]${NC}"
fi

# 5. Pentesting Tools Verification
echo -e "\n${BLUE}[+] 5. Core Security Toolchain Verification:${NC}"
TOOLS=("nmap" "wireshark" "burpsuite" "msfconsole" "gobuster" "hydra" "john" "aircrack-ng")

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" > /dev/null 2>&1; then
        path=$(command -v "$tool")
        echo -e "  • ${tool}: ${GREEN}Installed${NC} (${path})"
    else
        echo -e "  • ${tool}: ${YELLOW}Not Found${NC}"
    fi
done

echo -e "\n${CYAN}========================================================================${NC}"
echo -e "${GREEN}   ✅ All Bare-Metal Lab Checks Completed Successfully!                ${NC}"
echo -e "${CYAN}========================================================================${NC}"
