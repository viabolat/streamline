#!/bin/bash

# Ensure this script is always executable
chmod +x "$0"

# Path to the backup directory
BACKUP_DIR="$HOME/projects/bash_files/bashrc_backups"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Path to .bashrc
BASHRC="$HOME/.bashrc"

# Backup file name with timestamp
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="$BACKUP_DIR/.bashrc-$TIMESTAMP"

# Make a temporary copy of the original
TEMP_FILE="$BACKUP_DIR/.bashrc-temp"
cp "$BASHRC" "$TEMP_FILE"

# Edit .bashrc with nano
nano "$BASHRC"

# Check if the file was changed
if ! cmp -s "$BASHRC" "$TEMP_FILE"; then
    # Files are different, save a backup
    cp "$BASHRC" "$BACKUP_FILE"
    echo "Changes made and backup created: $BACKUP_FILE"
    
    # Handling the removal of older files, keeping the last 2 backups
    cd "$BACKUP_DIR"
    while [ $(ls -1 .bashrc-* | wc -l) -gt 4 ]; do
        OLDEST=$(ls -t .bashrc-* | tail -1)
        rm "$OLDEST"
        echo "Removed older backup: $OLDEST"
    done
else
    echo "No changes made, no backup created."
fi

# Remove the temporary file
rm "$TEMP_FILE"
