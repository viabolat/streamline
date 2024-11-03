#!/bin/bash

# Environment Variables and PATH adjustments
export AWS_REGION=eu-west-1
export DOCKER_HOST=localhost:2375
echo "AWS_REGION set to: $AWS_REGION"
echo "DOCKER_HOST set to: $DOCKER_HOST"

# Function to add paths to ensure no duplicates
add_to_path () {
  if [[ ":$PATH:" != *":$1:"* ]] && [ -d "$1" ]; then
    export PATH="$1:$PATH"
  elif [ ! -e "$1" ]; then
    echo "Error: Path $1 does not exist."
  fi
}

# Add essential paths for deployment
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/projects/bash_files"
add_to_path "$HOME/.tfenv/bin"
add_to_path "/usr/bin/python3.10"
add_to_path "/usr/bin/python3.11"
add_to_path "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/"
add_to_path "/mnt/c/Program Files/Docker/Docker/resources/bin"

# SSH Agent Setup - Check if SSH agent is running and start if necessary
if [ -z "$SSH_AUTH_SOCK" ] || ! pgrep -u "$USER" ssh-agent > /dev/null; then
  echo "Starting a new SSH agent..."
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa  # Add your key
else
  echo "SSH agent already running."
fi

# Docker Desktop for Windows Setup
if grep -qi microsoft /proc/version; then
    echo "Checking Docker..."
    if powershell.exe -Command "Get-Process -Name 'Docker Desktop' -ErrorAction SilentlyContinue" | grep -q "Docker Desktop"; then
        echo "Docker is currently running"
    else
        # If Docker Desktop is not running, start it without prompting
        echo "Starting Docker Desktop for Windows..."
        /mnt/c/Program\ Files/Docker/Docker/Docker\ Desktop.exe &
        echo "Docker Desktop is starting..."
    fi
fi

# Sourcing Additional Files (if any exist)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Navigate to the deployment project directory
cd ~/projects/clones

# Final confirmation of setup
echo "Deployment environment setup complete."
