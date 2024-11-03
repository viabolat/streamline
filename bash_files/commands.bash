################################################################################################################
## SSH AGENT SETUP AND TROUBLESHOOTING COMMANDS ##
# Generate SSH Key: Creates a new SSH key pair.
ssh-keygen -t rsa -C "your_email@example.com"

# Start the SSH agent: Initializes SSH agent in background.
eval $(ssh-agent)

# Add SSH key to agent: Registers private key with SSH agent.
ssh-add ~/.ssh/id_rsa

# Verify environment variables: Displays SSH agent PID and socket.
echo $SSH_AGENT_PID
echo $SSH_AUTH_SOCK

# Set key file permissions: Secures key files with correct permissions.
chmod 600 ~/.ssh/id_rsa
chmod 700 ~/.ssh

# Add SSH agent to .bashrc: Ensures SSH agent starts with shell.
echo '
if [ -z "$(pgrep ssh-agent)" ]; then
    eval $(ssh-agent -s)
else
    export SSH_AGENT_PID=$(pgrep ssh-agent)
    export SSH_AUTH_SOCK=$(find /tmp/ssh-* -name agent.*)
fi
' >> ~/.bashrc

# Output public key: Displays SSH public key for sharing.
cat ~/.ssh/id_rsa.pub

################################################################################################################
## SSH KEY PERMISSION ISSUES AND BITBUCKET SETUP ##
# Set key file permissions and verify: Ensures SSH key file is secured.
chmod 600 <path_to_ssh_key>
ls -l <path_to_ssh_key>

# Add SSH key from original location: Registers SSH key from specific path.
ssh-add <path_to_ssh_key>
ssh-add -l

# Test SSH connection: Verifies connectivity to Bitbucket.
ssh -T git@bitbucket.org

################################################################################################################
## SETTING UP AND TESTING YOUR SSH CONNECTION TO BITBUCKET ##
# Test network connectivity: Checks internet connection to Bitbucket.
ping bitbucket.org

# Move SSH key and setup config: Organizes SSH key and configures SSH.
mv <path_to_ssh_key> ~/.ssh/
nano ~/.ssh/config
echo "Host bitbucket.org
    AddKeysToAgent yes
    IdentityFile ~/.ssh/<custom_key_name>" >> ~/.ssh/config

# Verify SSH configuration: Tests if SSH setup is correct.
ssh -T git@bitbucket.org

################################################################################################################
## MIGRATION AND CI/CD SETUP ##
# Clone and setup repository: Mirrors Bitbucket repository for migration.
git clone --mirror <bitbucket_ssh_url> <folder_name>.git
mv <folder_name>.git <folder_name>
git remote update

# Setup new GitHub origin and push: Redirects repository to new GitHub origin.
git remote add new-origin <github_ssh_url>
git push --all new-origin
git push --tags new-origin

# Clean up and rename origins: Removes old and renames new Git origin.
git remote rm origin
git remote rename new-origin origin

# Commit and push CI/CD configs: Adds and commits CI/CD configurations to Git.
git add .
git commit -m "Setup CI/CD configurations"
git push

# Set global Git configurations: Configures Git user details globally.
git config --global user.email <email>
git config --global user.name <name_surname>

# Rename project folder: Renames base directory for clarity.
mv <folder_name> <new_repo_name>

################################################################################################################
## MIXED COMMANDS ##
# Check Python executable paths and versions.
which python3.10
which python3.11
python3.10 --version
python3.11 --version

# Update system packages and manage Python with pip.
sudo apt update
sudo apt install python3.8
python3.8 -m pip install <package-name>
python3.8 -m pip list
python3.8 -m pip uninstall <package-name>

# Display Docker system information and manage Docker service.
docker info
sudo service docker start

# Set environment variables and configure aliases.
export PATH=$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/
export AWS_REGION=eu-west-1
alias python='python3.10'
alias python3='python3.10'

# Copy .bashrc file to destination
cp ~/.bashrc /mnt/c/Users/ahmet.bolat/Desktop/