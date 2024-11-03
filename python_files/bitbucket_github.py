# ===bitbucket_to_github_migration===

import subprocess
import json
import platform
import os

# Load configuration from JSON file
configs = {}
with open('./configuration.json') as f:
    configs = json.load(f)

# Extract folder name from Bitbucket SSH URL
def extract_folder_name():
    return configs["bitbucket_ssh_url"].split("/")[-1].replace('.git', '')

# Extract new repository name from GitHub SSH URL
def extract_new_repo_name():
    return configs["github_ssh_url"].split("/")[-1].replace('.git', '')

# Extract account name from GitHub SSH URL
def extract_account_name_from_ssh_url():
    return configs["github_ssh_url"].split("/")[-1].replace('.git', '').split("-")[0]

# Clone and fetch Bitbucket repository
def clone_and_fetch_bitbucket():
    folder_name = extract_folder_name()
    print(f"Cloning into folder: {folder_name}")

    subprocess.run(["git", "clone", "--mirror", configs["bitbucket_ssh_url"], f"{folder_name}.git"])
    os.rename(f"{folder_name}.git", folder_name)

    if not os.path.isdir(folder_name):
        print(f"Error: The directory {folder_name} was not created.")
        return

    subprocess.run(["git", "remote", "update"], cwd=folder_name)

# Add new origin for GitHub repository
def add_new_origin():
    subprocess.run(["git", "remote", "add", "new-origin", configs["github_ssh_url"]], cwd=extract_folder_name())

# Push to new origin
def push_to_new_origin():
    subprocess.run(["git", "push", "--all", "new-origin"], cwd=extract_folder_name())
    subprocess.run(["git", "push", "--tags", "new-origin"], cwd=extract_folder_name())

# Edit remotes
def edit_remotes():
    subprocess.run(["git", "remote", "rm", "origin"], cwd=extract_folder_name())
    subprocess.run(["git", "remote", "rename", "new-origin", "origin"], cwd=extract_folder_name())

# Push base CI/CD files
def push_base_cicd_file():
    folder_path = os.path.join(extract_folder_name(), ".github", "workflows")
    os.makedirs(folder_path, exist_ok=True)

    if platform.system() == "Windows":
        subprocess.run(["copy", "dev-base-cicd.yaml", f"{folder_path}\\dev-cicd.yaml"], shell=True)
        subprocess.run(["copy", "int-base-cicd.yaml", f"{folder_path}\\int-cicd.yaml"], shell=True)
        subprocess.run(["copy", "prod-base-cicd.yaml", f"{folder_path}\\prod-cicd.yaml"], shell=True)
    else:
        subprocess.run(["cp", "dev-base-cicd.yaml", f"{folder_path}/dev-cicd.yaml"])
        subprocess.run(["cp", "int-base-cicd.yaml", f"{folder_path}/int-cicd.yaml"])
        subprocess.run(["cp", "prod-base-cicd.yaml", f"{folder_path}/prod-cicd.yaml"])

    subprocess.run(["git", "add", "."], cwd=extract_folder_name())
    subprocess.run(["git", "commit", "-m", "base ci-cd files"], cwd=extract_folder_name())
    subprocess.run(["git", "push"], cwd=extract_folder_name())

# Configure CI/CD files
def configure_cicd_files():
    base_yaml = open("./base-cicd.yaml", 'r').read()
    base_yaml = base_yaml.replace("<YOUR_PIPELINE_NAME>", f"{extract_new_repo_name()}-dev")
    base_yaml = base_yaml.replace("<YOUR_BRANCH_TO>", "development")
    base_yaml = base_yaml.replace("<REPO_NAME>", extract_new_repo_name())
    base_yaml = base_yaml.replace("<REGION>", configs["AWS_Region"])
    base_yaml = base_yaml.replace("<AWS_ID>", f"AWS_{extract_account_name_from_ssh_url().upper()}_DEV_ACCESS_KEY_ID")
    base_yaml = base_yaml.replace("<AWS_SECRET>", f"AWS_{extract_account_name_from_ssh_url().upper()}_DEV_ACCESS_KEY_SECRET")
    with open('dev-base-cicd.yaml', 'w') as file:
        file.write(base_yaml)

    base_yaml = open("./base-cicd.yaml", 'r').read()
    base_yaml = base_yaml.replace("<YOUR_PIPELINE_NAME>", f"{extract_new_repo_name()}-int")
    base_yaml = base_yaml.replace("<YOUR_BRANCH_TO>", "integration")
    base_yaml = base_yaml.replace("<REPO_NAME>", extract_new_repo_name())
    base_yaml = base_yaml.replace("<REGION>", configs["AWS_Region"])
    base_yaml = base_yaml.replace("<AWS_ID>", f"AWS_{extract_account_name_from_ssh_url().upper()}_INT_ACCESS_KEY_ID")
    base_yaml = base_yaml.replace("<AWS_SECRET>", f"AWS_{extract_account_name_from_ssh_url().upper()}_INT_ACCESS_KEY_SECRET")
    with open('int-base-cicd.yaml', 'w') as file:
        file.write(base_yaml)

    base_yaml = open("./base-cicd.yaml", 'r').read()
    base_yaml = base_yaml.replace("<YOUR_PIPELINE_NAME>", f"{extract_new_repo_name()}-prod")
    base_yaml = base_yaml.replace("<YOUR_BRANCH_TO>", "master")
    base_yaml = base_yaml.replace("<REPO_NAME>", extract_new_repo_name())
    base_yaml = base_yaml.replace("<REGION>", configs["AWS_Region"])
    base_yaml = base_yaml.replace("<AWS_ID>", f"AWS_{extract_account_name_from_ssh_url().upper()}_PROD_ACCESS_KEY_ID")
    base_yaml = base_yaml.replace("<AWS_SECRET>", f"AWS_{extract_account_name_from_ssh_url().upper()}_PROD_ACCESS_KEY_SECRET")
    with open('prod-base-cicd.yaml', 'w') as file:
        file.write(base_yaml)

# Change base folder name
def change_base_folder_name():
    if platform.system() == "Windows":
        subprocess.run(["powershell", "Rename-Item", extract_folder_name(), extract_new_repo_name()], shell=True)
    else:
        subprocess.run(["mv", extract_folder_name(), extract_new_repo_name()])

# Add global Git configurations
def add_git_global_configs():
    subprocess.run(["git", "config", "--global", "user.email", configs["email"]])
    subprocess.run(["git", "config", "--global", "user.name", configs["name_surname"]])

# Main function
def main():
    add_git_global_configs()
    clone_and_fetch_bitbucket()
    add_new_origin()
    push_to_new_origin()
    edit_remotes()
    configure_cicd_files()
    push_base_cicd_file()
    change_base_folder_name()

main()
