# Write a shell script to check the status of a list of URLs and send an email notification if any of them are down.

#!/bin/bash

# Configuration
URLS=("https://www.example.com" "http://www.anotherexample.com" "https://your.website.com") # Replace with your URLs
RECIPIENT_EMAIL="your_email@example.com" # Replace with your email
OUTPUT_FILE="url_status.txt"
ALERT_FILE="url_alert.txt"

# Function to check URL status
check_url_status() {
  local url="$1"
  local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

  if [[ -z "$status_code" ]]; then
    echo "Error: Could not connect to $url"
    return 1
  fi

  if [[ "$status_code" -ge 400 ]]; then
    echo "Error: $url returned status code $status_code"
    return 1
  else
    echo "$url is up (status code: $status_code)"
    return 0
  fi
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

# Function to monitor URLs
monitor_urls() {
  local alert_message=""

  echo "URL Status Check:" > "$OUTPUT_FILE"
  echo "-----------------" >> "$OUTPUT_FILE"

  for url in "${URLS[@]}"; do
    if check_url_status "$url"; then
      echo "$url is down." >> "$OUTPUT_FILE"
      alert_message+="$url is down.\n"
    else
      echo "$url is up." >> "$OUTPUT_FILE"
    fi
  done

  if [[ -n "$alert_message" ]]; then
    echo "$alert_message" > "$ALERT_FILE"
    send_email_alert "URL Down Alert" "$alert_message"
    echo "Alert sent and written to $ALERT_FILE"
  else
    echo "All URLs are up." >> "$OUTPUT_FILE"
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
monitor_urls
