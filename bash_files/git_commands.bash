############ Starting a New Project ############

# Initialize a local Git repository.
git init
# Clone a repository into a new directory.
git clone <repository_url>

############ Daily Workflow ############

# Show the working tree status.
git status
# Add all new and changed files to the index.
git add .
# Add a specific file to the index.
git add <file_or_directory>
# Record changes to the repository with a commit message.
git commit -m "<commit_message>"
# Fetch updates from the remote but do not merge.
git fetch <remote>
# Pull changes from the remote repository and merge.
git pull <remote> <branch>

############ Branch Management ############

# List all local branches.
git branch
# Create a new branch and switch to it.
git checkout -b <new_branch>
# Switch to an existing branch.
git checkout <branch_or_commit_or_tag>
# Merge a branch into the current branch.
git merge <branch>
# Delete a local branch.
git branch -d <branch>
# Push local branch changes to the remote repository.
git push <remote> <branch>
# Set up a new remote for the repository.
git remote add <remote_name> <remote_url>
# Push all branches to the remote.
git push --all <remote>

############ Stashing and Cleaning ############

# Stash changes in the working directory.
git stash
# Apply stashed changes and keep them in the stash.
git stash apply
# Apply stashed changes and remove them from the stash.
git stash pop
# List all stashes.
git stash list
# Drop the latest stashed state.
git stash drop
# Remove untracked files from the working tree.
git clean -f
# Perform a dry run to see what 'git clean' would delete without actually deleting anything
git clean -nfd
# Remove untracked files and directories.
git clean -fd
# Delete uncommited changes and reset to previous head
git reset --hard
# Restore all modified files to their last committed state, discarding changes
git restore .

############ Advanced Usage ############

# Modify the last commit without changing its commit message.
git commit --amend --no-edit
# Show changes made by commits, visually.
git log --graph
# Show what revision and author last modified each line of a file.
git blame <file>
# Create an annotated tag.
git tag -a <tag_name> -m "<tag_message>"
# Push tags to the remote repository.
git push --tags
# Add a submodule.
git submodule add <repository> <path>
# Initialize submodule configurations.
git submodule init
# Update submodules after fetching.
git submodule update
# Start a binary search to find the commit that introduced a bug.
git bisect start
# Mark the current commit as good.
git bisect good
# Mark the current commit as bad.
git bisect bad
# Finish the bisect session and return to the previous branch.
git bisect reset
