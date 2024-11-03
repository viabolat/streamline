#!/bin/bash

# Function to add paths while ensuring no duplicates
add_to_path () {
  if [ -e "$1" ]; then  # Check if the path exists
    case ":$PATH:" in
      *":$1:"*) echo "Path $1 already exists in PATH."
        ;;
      *) export PATH="$1:$PATH"
         echo "Added $1 to PATH."
        ;;
    esac
  else
    echo "Error: Path $1 does not exist."
    return 1
  fi
}

# Initial PATH setting for the test
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

echo "Initial PATH: $PATH"

# Testing with an existing path
add_to_path "/bin"

# Testing with a new path that exists
add_to_path "/usr/local/bin"  # Assuming /usr/local/bin exists

# Testing with a new path that does not exist
add_to_path "/fakepath"

# Testing adding the same new path again
add_to_path "/usr/local/bin"

echo "Final PATH: $PATH"
