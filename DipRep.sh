#!/bin/bash

install_gh() {
    case "$OSTYPE" in
        linux*)
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install gh -y
            elif command -v dnf &> /dev/null; then
                sudo dnf install gh -y
            elif command -v pacman &> /dev/null; then
                sudo pacman -S gh
            elif command -v yum &> /dev/null; then
                sudo yum install gh -y
            elif command -v zypper &> /dev/null; then
                sudo zypper install gh
            elif command -v eopkg &> /dev/null; then
                sudo eopkg install gh
            elif command -v emerge &> /dev/null; then
                sudo emerge --ask app-misc/gh
            else
                echo "Unknown Linux distribution. Please install GitHub CLI manually."
                exit 1
            fi
            ;;
        darwin*)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not installed. Please install Homebrew and then run this script again."
                exit 1
            fi
            brew install gh
            ;;
        msys*)
            if ! command -v choco &> /dev/null; then
                echo "Chocolatey not installed. Please install Chocolatey and then run this script again."
                exit 1
            fi
            choco install gh
            ;;
        *)
            echo "Unknown operating system. Please install GitHub CLI manually."
            exit 1
            ;;
    esac
}

install_jq() {
    case "$OSTYPE" in
        linux*)
            if command -v apt-get &> /dev/null; then
                sudo apt-get install jq -y
            elif command -v dnf &> /dev/null; then
                sudo dnf install jq -y
            elif command -v pacman &> /dev/null; then
                sudo pacman -S jq
            elif command -v yum &> /dev/null; then
                sudo yum install jq -y
            elif command -v zypper &> /dev/null; then
                sudo zypper install jq
            elif command -v eopkg &> /dev/null; then
                sudo eopkg install jq
            elif command -v emerge &> /dev/null; then
                sudo emerge --ask app-misc/jq
            else
                echo "Unknown Linux distribution. Please install jq manually."
                exit 1
            fi
            ;;
        darwin*)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not installed. Please install Homebrew and then run this script again."
                exit 1
            fi
            brew install jq
            ;;
        msys*)
            if ! command -v choco &> /dev/null; then
                echo "Chocolatey not installed. Please install Chocolatey and then run this script again."
                exit 1
            fi
            choco install jq
            ;;
        *)
            echo "Unknown operating system. Please install jq manually."
            exit 1
            ;;
    esac
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

