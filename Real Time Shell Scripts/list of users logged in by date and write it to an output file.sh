# Write a shell script to the list of users logged in by date and write it to an output file.

#!/bin/bash

# Function to list logged-in users by date and write to a file
list_users_by_date() {
  local output_file="logged_in_users.txt"

  # Use 'last' command to get login information
  last | awk '{print $1, $3, $4, $5, $6, $7, $8, $9, $10}' > "$output_file"

  # Check if the file was created
  if [[ -f "$output_file" ]]; then
    echo "Logged-in user information written to $output_file."
  else
    echo "Failed to write user information to $output_file."
    return 1
  fi
}

# Example usage:
list_users_by_date
