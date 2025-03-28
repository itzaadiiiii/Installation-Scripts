# Shell script to find the files created and their sizes. It should accept the number of days as input. Or a from and to date format as inputs.

#!/bin/bash

# Function to find files created within a specified time range
find_files_by_time() {
  local days="$1"
  local from_date="$2"
  local to_date="$3"

  # Check for valid input
  if [[ -z "$days" && ( -z "$from_date" || -z "$to_date" ) ]]; then
    echo "Usage: $0 <days> OR $0 <from_date> <to_date> (YYYY-MM-DD)"
    return 1
  fi

  local find_command="find / -xdev -type f -print0 2>/dev/null"

  if [[ -n "$days" ]]; then
    find_command+=" -mtime -$days"
  elif [[ -n "$from_date" && -n "$to_date" ]]; then
    local from_seconds=$(date -d "$from_date 00:00:00" +%s 2>/dev/null)
    local to_seconds=$(date -d "$to_date 23:59:59" +%s 2>/dev/null)

    if [[ -z "$from_seconds" || -z "$to_seconds" ]]; then
      echo "Invalid date format. Use YYYY-MM-DD."
      return 1
    fi

    find_command+=" -newermt \"$(date -d @$from_seconds +'%Y-%m-%d %H:%M:%S')\" ! -newermt \"$(date -d @$to_seconds +'%Y-%m-%d %H:%M:%S')\""
  fi

  $find_command | xargs -0 ls -lhS 2>/dev/null
}

# Example usage:
# Find files created in the last 7 days:
# find_files_by_time 7

# Find files created between two dates:
# find_files_by_time "" "2023-10-26" "2023-11-01"
