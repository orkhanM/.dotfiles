#!/bin/bash

# Function to compress a path
compress_path() {
  local path="$1"
  local home_dir="$HOME"

  # Check if path is in user's home directory
  if [[ "$path" == "$home_dir"* ]]; then
    # Replace home directory with ~
    local rel_path="${path#$home_dir}"
    # Split the path into components
    IFS='/' read -ra path_parts <<<"$rel_path"

    local result="~"
    # Process each path component except the last one
    for ((i = 1; i < ${#path_parts[@]} - 1; i++)); do
      result="$result/${path_parts[$i]:0:1}"
    done

    # Add the last component in full if it exists
    if [ ${#path_parts[@]} -gt 1 ]; then
      result="$result/${path_parts[${#path_parts[@]} - 1]}"
    fi

    echo "$result"
  else
    # For paths outside home directory
    # Split the path into components
    IFS='/' read -ra path_parts <<<"$path"

    local result=""
    # Process each path component except the last one
    for ((i = 1; i < ${#path_parts[@]} - 1; i++)); do
      result="$result/${path_parts[$i]:0:1}"
    done

    # Add the last component in full if it exists
    if [ ${#path_parts[@]} -gt 1 ]; then
      result="$result/${path_parts[${#path_parts[@]} - 1]}"
    fi

    echo "$result"
  fi
}

# Check if a path argument was provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

# Compress and output the path
compress_path "$1"
