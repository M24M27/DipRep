# DipRep
A comprehensive shell script that automates the process of cloning a GitHub repository. The script checks for and installs required dependencies, authenticates the GitHub CLI, retrieves the user's repositories, and clones the selected repository into a specified or newly created directory.
# GitHub Repository Clone Automation

## Description
This repository contains a shell script that automates the cloning of a GitHub repository. The script handles the installation of necessary dependencies (`jq` and `gh`), GitHub CLI authentication, retrieval of user's repositories, and clones the selected repository into a specified or newly created directory.

## Prerequisites
- Bash shell
- GitHub account
- GitHub CLI installed and authenticated (if not, the script will guide through the installation and authentication)

## Usage
1. Clone this repository and navigate to the repository folder.
2. Make the script executable by running `chmod +x script_name.sh`.
3. Execute the script by running `./script_name.sh`.
4. Follow the prompts to clone the desired repository.

## Note
- The script will prompt for the GitHub username to retrieve the list of repositories.
- The script will then prompt to select a repository from the list to clone.
- Lastly, the script will prompt to choose the directory to clone the repository into.

## Contributions
Contributions, issues, and feature requests are welcome!

## License
This project is under the MIT License. See `LICENSE` for more information.
