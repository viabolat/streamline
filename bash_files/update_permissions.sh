#!/bin/bash

# Ensure this script is always executable
chmod +x "$0"

# Get the root directory of the current Git repository
ROOT_DIR=$(git rev-parse --show-toplevel 2>&1)

# Check if in a Git repository
if [[ $? -ne 0 ]]; then
    echo "Error finding git repository: $ROOT_DIR"
    exit 1
fi

echo "Project root determined as: $ROOT_DIR"

# Define the path to deploy.sh within the project
DEPLOY_PATH="$ROOT_DIR/infrastructure/deploy.sh"
if [[ -f "$DEPLOY_PATH" ]]; then
    # Make deploy.sh executable and fix line endings
    chmod +x "$DEPLOY_PATH"
    sed -i 's/\r$//' "$DEPLOY_PATH"
    echo "chmod +x and sed applied to $DEPLOY_PATH"
else
    echo "deploy.sh not found at $DEPLOY_PATH"
fi

# Find and modify all execute_code.sh files in .terraform directories
find "$ROOT_DIR" -type f -path "*/.terraform/*" -name "execute_code.sh" | sort | uniq -u | while read filename; do
    chmod +x "$filename"
    sed -i 's/\r$//' "$filename"
    echo "chmod +x and sed applied to $filename"
done
echo "Modifications completed for execute_code.sh scripts in .terraform directories under $ROOT_DIR"
