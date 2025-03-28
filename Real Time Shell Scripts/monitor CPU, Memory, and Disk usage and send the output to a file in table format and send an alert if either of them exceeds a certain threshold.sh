# Shell script to monitor CPU, Memory, and Disk usage and send the output to a file in table format and send an alert if either of them exceeds a certain threshold.

#!/bin/bash

# Configuration
CPU_THRESHOLD=90
MEMORY_THRESHOLD=90
DISK_THRESHOLD=90
OUTPUT_FILE="system_monitor.txt"
ALERT_FILE="alert.txt"
RECIPIENT_EMAIL="your_email@example.com" # Replace with your email

# Function to get CPU usage
get_cpu_usage() {
  top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1"
}

# Function to get memory usage
get_memory_usage() {
  free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }'
}

# Function to get disk usage of root partition
get_disk_usage() {
  df -h / | awk 'NR==2{print $5+0}'
}

# Function to send email alert
send_email_alert() {
  local subject="$1"
  local body="$2"

  if [[ -n "$RECIPIENT_EMAIL" ]]; then
      ./send_email.sh "$RECIPIENT_EMAIL" "$subject" "$body"
  else
      echo "RECIPIENT_EMAIL not set. Alert not sent."
  fi
}

# Function to monitor system resources
monitor_system() {
  local cpu_usage=$(get_cpu_usage)
  local memory_usage=$(get_memory_usage)
  local disk_usage=$(get_disk_usage)
  local alert_message=""

  # Write output to file in table format
  echo "--------------------------------------------------------" > "$OUTPUT_FILE"
  echo "| Resource | Usage (%) | Threshold (%) |" >> "$OUTPUT_FILE"
  echo "--------------------------------------------------------" >> "$OUTPUT_FILE"
  printf "| %-8s | %-9s | %-13s |\n" "CPU" "$cpu_usage" "$CPU_THRESHOLD" >> "$OUTPUT_FILE"
  printf "| %-8s | %-9s | %-13s |\n" "Memory" "$memory_usage" "$MEMORY_THRESHOLD" >> "$OUTPUT_FILE"
  printf "| %-8s | %-9s | %-13s |\n" "Disk" "$disk_usage" "$DISK_THRESHOLD" >> "$OUTPUT_FILE"
  echo "--------------------------------------------------------" >> "$OUTPUT_FILE"

  # Check for thresholds and generate alert message
  if [[ $(echo "$cpu_usage > $CPU_THRESHOLD" | bc) -eq 1 ]]; then
    alert_message+="CPU usage ($cpu_usage%) exceeds threshold ($CPU_THRESHOLD%).\n"
  fi
  if [[ $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc) -eq 1 ]]; then
    alert_message+="Memory usage ($memory_usage%) exceeds threshold ($MEMORY_THRESHOLD%).\n"
  fi
  if [[ "$disk_usage" -gt "$DISK_THRESHOLD" ]]; then
    alert_message+="Disk usage ($disk_usage%) exceeds threshold ($DISK_THRESHOLD%).\n"
  fi

  # Send alert if necessary
  if [[ -n "$alert_message" ]]; then
    echo "$alert_message" > "$ALERT_FILE"
    send_email_alert "System Resource Alert" "$alert_message"
    echo "Alert sent and written to $ALERT_FILE"
  else
    echo "No threshold exceeded."
  fi
}

# Include send_email.sh script
if [[ -f "./send_email.sh" ]] ; then
    source ./send_email.sh
else
    echo "send_email.sh not found. Email alert disabled."
    RECIPIENT_EMAIL=""
fi

# Run the monitoring function
monitor_system
