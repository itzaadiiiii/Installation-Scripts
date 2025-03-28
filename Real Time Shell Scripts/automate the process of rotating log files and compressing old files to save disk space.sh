# Write a shell script to automate the process of rotating log files and compressing old files to save disk space.

#!/bin/bash

# Configuration
LOG_DIR="/var/log"
LOG_FILES="*.log"
MAX_FILES=7
COMPRESS_OLD=true
COMPRESS_TYPE="gzip" # or bzip2, xz

# Function to rotate and compress log files
rotate_logs() {
  local os_type

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

  # Change directory to log directory
  cd "$LOG_DIR" || { echo "Cannot change to directory $LOG_DIR"; return 1; }

  # Rotate log files
  for log in $LOG_FILES; do
    if [[ -f "$log" ]]; then
      if [[ -f "$log.$MAX_FILES" ]]; then
        rm -f "$log.$MAX_FILES"
      fi

      for ((i=MAX_FILES-1; i>=1; i--)); do
        if [[ -f "$log.$i" ]]; then
          mv "$log.$i" "$log.$((i+1))"
        fi
      done

      if [[ -f "$log" ]]; then
        mv "$log" "$log.1"
      fi
    fi
  done

  # Compress old log files
  if [[ "$COMPRESS_OLD" == true ]]; then
    for log in $LOG_FILES.[2-$MAX_FILES]; do
      if [[ -f "$log" ]]; then
        case "$COMPRESS_TYPE" in
          gzip)
            gzip "$log"
            ;;
          bzip2)
            bzip2 "$log"
            ;;
          xz)
            xz "$log"
            ;;
          *)
            echo "Unsupported compression type: $COMPRESS_TYPE"
            ;;
        esac
      fi
    done
  fi
}

# Example usage:
rotate_logs
