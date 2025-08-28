#!/bin/bash

: <<'COMMENT'
This script clones a GitHub repository and sets up the remotes for a forked repository.
Ⓒ 2025 Oleg'Ease'Kharchuk ᦒ
COMMENT

set -euo pipefail

main() {
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null; then
        printf "Error: 'gh' command not found. Please install GitHub CLI from https://cli.github.com/ \n" >&2
        exit 1
    fi
    # Determine default owner
    local DEFAULT_OWNER
    if ! DEFAULT_OWNER=$(gh api user --jq .login 2>/dev/null); then
        printf "Error: Could not determine GitHub user. Please run 'gh auth login'." >&2
        exit 1
    fi
    # Process repository path
    local REPO_PATH="$1"
    if ! [[ "$REPO_PATH" == */* ]]; then
        printf "Info: No owner specified, assuming '$DEFAULT_OWNER', path set to '$DEFAULT_OWNER/$REPO_PATH'\n"
        REPO_PATH="$DEFAULT_OWNER/$REPO_PATH"
    fi
    # Check if directory already exists
    if [ -d "$REPO_PATH" ]; then
        printf "Error: Directory '$REPO_PATH' already exists\n"
        exit 1
    fi
    # Check if repository exists on GitHub
    if ! gh repo view "$REPO_PATH" &> /dev/null; then
        printf "Error: Could not find repository '$REPO_PATH' on GitHub\n"
        exit 1
    fi
    # clone the repository
    local OWNER=$(dirname "$REPO_PATH")
    local REPO=$(basename "$REPO_PATH")
    mkdir -p "$OWNER"
    cd "$OWNER"
    gh repo clone "$REPO_PATH"
    cd "$REPO"
    # rename remotes
    if git remote get-url upstream &> /dev/null; then
        git remote rename origin fork
        git remote rename upstream root
    else
        printf "Not a fork, rename origin to original\n"
        git remote rename origin original
    fi
    # final message
    printf "\nDone! Remote configuration:\n"
    git remote -v
}
# Check if repository path is provided
if [ "$#" -ne 1 ]; then
    printf "Error: This script requires exactly one argument.\n" >&2
    printf "Usage: %s <[owner/]repo>\n" "$(basename "$0")" >&2
    exit 1
fi
main "$1"
