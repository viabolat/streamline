#!/bin/bash

# Ensure this script is always executable
chmod +x "$0"

# Environment Variables and PATH adjustments
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/projects/bash_files:$PATH"
export AWS_REGION=eu-west-1
export DOCKER_HOST=localhost:2375
echo "AWS_REGION set to: $AWS_REGION"
echo "DOCKER_HOST set to: $DOCKER_HOST"

# Path Settings - Ensure no duplicates
add_to_path () {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH";;
  esac
}

# Add paths
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.tfenv/bin"
add_to_path "/usr/bin/python3.10"
add_to_path "/usr/bin/python3.11"
add_to_path "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/"
add_to_path "/mnt/c/Program Files/Docker/Docker/resources/bin"

# SSH Agent Setup - Check if SSH agent is running and start one only if necessary
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
    # Check if Docker Desktop is running using PowerShell
    if powershell.exe -Command "Get-Process -Name 'Docker Desktop' -ErrorAction SilentlyContinue" | grep -q "Docker Desktop"; then
        echo "Docker is currently running"
    else
        # If Docker Desktop is not running, ask to start it
        read -p "Docker Desktop is not running. Start Docker Desktop? (y/n) " -n 1 -r
        echo    # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Starting Docker Desktop for Windows..."
            /mnt/c/Program\ Files/Docker/Docker/Docker\ Desktop.exe &
            echo "Docker Desktop is starting..."
        fi
    fi
fi

# Interactive-only configurations
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

# Sourcing Additional Files
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

 cd ~/projects/clones
