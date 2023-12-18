#!/bin/bash

# Get the current date and time
current_time=$(date +"%Y-%m-%d %H:%M:%S")

# Display the system information
echo "System Status Report - $current_time"
echo "-----------------------------------"

# Display CPU usage
echo "1. CPU Usage:"
top -b -n 1 | grep "%Cpu"

# Display Memory usage
echo -e "\n2. Memory Usage:"
free -m

# Display running services
echo -e "\n3. Running Services:"
systemctl list-units --type=service --state=running

# Display disk space usage
echo -e "\n4. Disk Space Usage:"
df -h

# Display network information
echo -e "\n5. Network Information:"
ip a

# Display logged-in users
echo -e "\n6. Logged-in Users:"
who

# Display system uptime
echo -e "\n7. System Uptime:"
uptime

echo "-----------------------------------"
echo "End of System Status Report"
