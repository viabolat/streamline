#!/bin/bash

# Ensure this script is always executable
chmod +x "$0"

# Directory containing all your repositories
REPOS_DIR="/home/ahmet_bolat/projects/clones"

# Initialize array to hold numbers of repositories with errors
declare -a error_repos
repo_count=0

# Loop through each directory in REPOS_DIR
for repo in "$REPOS_DIR"/*; do
  if [ -d "$repo/.git" ]; then
    cd "$repo"
    ((repo_count++))
    has_error=0
    echo "$repo_count. Updating repository: $repo"

    # Fetch latest changes from remote
    git fetch origin

    # Update main branch if it exists
    if git rev-parse --verify main >/dev/null 2>&1; then
      echo -n "  Checking out main... "
      if ! git checkout main 2>&1 || ! git pull origin main 2>&1; then
        has_error=1
        echo "Error updating main branch"
      fi
    fi

    # Update master branch if it exists
    if git rev-parse --verify master >/dev/null 2>&1; then
      echo -n "  Checking out master... "
      if ! git checkout master 2>&1 || ! git pull origin master 2>&1; then
        has_error=1
        echo "Error updating master branch"
      fi
    fi

    # Update develop branch if it exists
    if git rev-parse --verify develop >/dev/null 2>&1; then
      echo -n "  Checking out develop... "
      if ! git checkout develop 2>&1 || ! git pull origin develop 2>&1; then
        has_error=1
        echo "Error updating develop branch"
      fi
    fi

    # If there was an error, add this repo number to the list
    if [ "$has_error" -eq 1 ]; then
      error_repos+=("$repo_count")
    fi

    # Checkout back to the default branch (optional)
    git checkout main 2>/dev/null || git checkout master 2>/dev/null || git checkout develop 2>/dev/null
  else
    echo "$repo_count. $repo is not a git repository"
  fi
done

# Final output based on whether any errors were recorded
if [ ${#error_repos[@]} -eq 0 ]; then
  echo "Update process completed."
else
  echo "Updated repos. Please double check repo(s): ${error_repos[*]}"
fi
