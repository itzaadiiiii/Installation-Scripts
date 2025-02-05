#!/bin/bash

# Clear the screen
clear

echo "============================================"
echo "  🚀 SYSTEM MONITORING & HEALTH CHECK  "
echo "============================================"

# System Uptime
echo -e "\n📌 System Uptime:"
uptime -p

# CPU Usage
echo -e "\n🔥 CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print "Usage: " $2 "% user, " $4 "% system, " $8 "% idle"}'

# Memory Usage
echo -e "\n🧠 Memory Usage:"
free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)\n", $3, $2, $3/$2*100}'

# Disk Usage
echo -e "\n💾 Disk Usage:"
df -h | awk '$NF=="/"{printf "Used: %d/%d GB (%s)\n", $3, $2, $5}'

# Running Processes
echo -e "\n⚙️  Running Processes:"
ps aux --sort=-%mem | head -5

# Logged-in Users
echo -e "\n👥 Logged-in Users:"
who

# Network Status
echo -e "\n🌐 Network Interfaces:"
ip -c a | grep -E "state UP|inet " | awk '{print $2, $3}'

# Last Reboot
echo -e "\n🔄 Last Reboot:"
last reboot | head -1

echo -e "\n✅ System check complete!\n"

