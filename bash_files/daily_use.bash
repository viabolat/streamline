# Alias list

alias clones
alias deployment
alias editbashrc
alias home
alias mnt
alias reload
alias update_permissions
alias update_repos

# Copy .bashrc file to destination
cp ~/.bashrc /some/where

# Fix permission and LF issues (these are in the update_permissions script)
chmod +x deploy.sh
sed -i 's/\r$//' deploy.sh
chmod +x execute_code.sh
sed -i 's/\r$//' execute_code.sh

# Start the SSH agent: Initializes SSH agent in background.
eval $(ssh-agent)

# Add SSH key to agent: Registers private key with SSH agent.
ssh-add ~/.ssh/id_rsa

# AWScli to measure the size of a bucket
aws s3 ls --summarize --human-readable --recursive s3://<bucket_name>/

# AWScli to measure the size of specific table(s)
aws s3 ls --summarize --human-readable --recursive s3://<bucket_name>/<table_name>/

