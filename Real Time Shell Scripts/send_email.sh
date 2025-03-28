# Shell script to send Email :

#!/bin/bash

# Function to send an email
send_email() {
  local to="$1"
  local subject="$2"
  local body="$3"
  local os_type
  local mail_command

  # Check if required arguments are provided
  if [[ -z "$to" || -z "$subject" || -z "$body" ]]; then
    echo "Usage: $0 <to_email> <subject> <body>"
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

  # Determine the mail command based on the OS.
  case "$os_type" in
    ubuntu|debian)
      if command -v mailx >/dev/null 2>&1; then
        mail_command="mailx -s \"$subject\" \"$to\" <<< \"$body\""
      elif command -v mail >/dev/null 2>&1; then
        mail_command="mail -s \"$subject\" \"$to\" <<< \"$body\""
      else
        echo "mail or mailx not found. Install one of them."
        return 1
      fi
      ;;
    centos|rhel|fedora|amazon)
      if command -v mail >/dev/null 2>&1; then
        mail_command="mail -s \"$subject\" \"$to\" <<< \"$body\""
      else
        echo "mail not found. Install mailx or mailutils."
        return 1
      fi
      ;;
    *)
      echo "Unsupported operating system: $os_type"
      return 1
      ;;
  esac

  # Send the email
  if eval "$mail_command"; then
    echo "Email sent successfully."
    return 0
  else
    echo "Failed to send email."
    return 1
  fi
}

# Example usage:
# send_email "recipient@example.com" "Subject of the email" "Body of the email."
