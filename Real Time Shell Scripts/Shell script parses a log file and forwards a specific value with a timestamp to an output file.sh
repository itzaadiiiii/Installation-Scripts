# Shell script parses a log file and forwards a specific value with a timestamp to an output file.

#!/bin/bash

# Function to parse a log file and extract values with timestamps
parse_log_file() {
  local log_file="$1"
  local search_pattern="$2"
  local output_file="$3"
  local os_type

  # Check for required arguments
  if [[ -z "$log_file" || -z "$search_pattern" || -z "$output_file" ]]; then
    echo "Usage: $0 <log_file> <search_pattern> <output_file>"
    return 1
  fi

  # Check if the log file exists
  if [[ ! -f "$log_file" ]]; then
    echo "Log file not found: $log_file"
    return 1
  fi

    # Determine the operating system
  if [[ -f /etc/os-release ]]; then
    os_type=$(grep -oP '(?<=^ID=).+' /etc/os-release)
  elif [[ -f /etc/redhat-release ]]; then
    os_type="centos"
  elif [[ -f /etc/debian_version ]]; then
    os_type="ubuntu"
  else
    echo "Unsupported operating system."
    return 1
  fi

  # Modify OS detection for amazon linux 2
  if [[ "$os_type" == "amzn" ]]; then
      os_type="amazon"
  fi

  # Parse the log file and extract values with timestamps
  grep "$search_pattern" "$log_file" | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30}' > "$output_file"

  # Check if the output file was created
  if [[ -f "$output_file" ]]; then
    echo "Log data extracted and written to $output_file."
  else
    echo "Failed to write log data to $output_file."
    return 1
  fi
}

# Example usage:
# parse_log_file "/var/log/syslog" "error" "errors.txt"
# parse_log_file "/var/log/apache2/access.log" "GET /api/" "api_requests.txt"
