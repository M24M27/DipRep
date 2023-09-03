#!/bin/bash

# Function to install GitHub CLI
install_gh() {
    echo "Installing GitHub CLI..."
    curl -sSL https://github.com/cli/cli/releases/download/v2.0.0/gh_2.0.0_linux_amd64.tar.gz | tar xz -C /tmp
    sudo mv /tmp/gh_2.0.0_linux_amd64/bin/gh /usr/local/bin/
}

# Function to install jq
install_jq() {
    sudo apt-get install jq -y
}

# Install jq if not installed
if ! command -v jq &> /dev/null; then
    install_jq
fi

# Install gh if not installed
if ! command -v gh &> /dev/null; then
    install_gh
fi

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo "GitHub CLI not authenticated. Please run 'gh auth login' and then run this script again."
    exit 1
fi

# Get GitHub token from gh configuration
token=$(grep 'oauth_token:' ~/.config/gh/hosts.yml | awk '{print $2}')

# Get user's GitHub username
read -p "Enter your GitHub username: " username

# Get user's GitHub repositories
repos=$(gh api "users/$username/repos" | jq -r '.[].name')

echo "Available repositories:"
counter=1
for repo in $repos; do
    echo "$counter. $repo"
    counter=$((counter + 1))
done

while true; do
    read -p "Enter the number of the repository to clone (or q to quit): " repo_number
    if [[ "$repo_number" == "q" || "$repo_number" == "Q" ]]; then
        exit 0
    fi

    if [[ "$repo_number" =~ ^[0-9]+$ ]] && [[ "$repo_number" -gt 0 ]] && [[ "$repo_number" -le $((counter - 1)) ]]; then
        break
    else
        echo "You entered the wrong command, please try again."
    fi
done

repo_name=$(echo "$repos" | sed "${repo_number}q;d")

while true; do
    read -p "Press 'c' to clone to the current directory, 's' to specify a directory, or 'n' to create a new directory: " choice
    case "$choice" in
        c|C)
            directory=$(pwd)
            break
            ;;
        s|S)
            read -p "Enter the directory to clone the repository into: " directory
            break
            ;;
        n|N)
            read -p "Enter the name of the new directory to create: " new_directory
            directory=$(pwd)/$new_directory
            mkdir -p "$directory"
            break
            ;;
        *)
            echo "You entered the wrong command, please try again."
            ;;
    esac
done

repo_url="https://github.com/$username/$repo_name.git"
git clone "$repo_url" "$directory/$repo_name"

# Navigate to the repository directory
cd "$directory/$repo_name"

# Get the path of the current script
SCRIPT_PATH=$(dirname $(realpath $0))

# Add the script's path to the PATH variable in .bashrc
echo "export PATH=$PATH:$SCRIPT_PATH" >> ~/.bashrc

# Reload .bashrc
source ~/.bashrc

echo "Repository successfully cloned!"
