#!/bin/sh

: <<'COMMENT'
This script clones a GitHub repository and sets up the remotes for a forked repository.
Ⓒ 2025 Oleg'Ease'Kharchuk ᦒ
COMMENT

set -eu

main() {
    # Check if GitHub CLI is installed
    if ! command -v gh >/dev/null 2>&1; then
        printf "Error: 'gh' command not found. Please install GitHub CLI from https://cli.github.com/ web page\n" >&2
        exit 1
    fi
    # Determine default owner
    DEFAULT_OWNER=$(gh api user --jq .login 2>/dev/null || true)
    if [ -z "$DEFAULT_OWNER" ]; then
        printf "Error: Could not determine GitHub user. Please run 'gh auth login'\n" >&2
        exit 1
    fi
    # Process repository path
    REPO_PATH="$1"
    if [ "$(expr index "$REPO_PATH" /)" -eq 0 ]; then
        printf "Info: No owner specified, assuming '%s', path set to '%s/%s'\n" "$DEFAULT_OWNER" "$DEFAULT_OWNER" "$REPO_PATH"
        REPO_PATH="$DEFAULT_OWNER/$REPO_PATH"
    fi
    # Check if directory already exists
    if [ -d "$REPO_PATH" ]; then
        printf "Error: Directory '%s' already exists\n" "$REPO_PATH"
        exit 1
    fi
    # Check if repository exists on GitHub
    if ! gh repo view "$REPO_PATH" >/dev/null 2>&1; then
        printf "Error: Could not find repository '%s' on GitHub\n" "$REPO_PATH"
        exit 1
    fi
    # clone the repository
    OWNER=$(dirname "$REPO_PATH")
    REPO=$(basename "$REPO_PATH")
    mkdir -p "$OWNER"
    cd "$OWNER" || exit 1
    gh repo clone "$REPO_PATH"
    cd "$REPO" || exit 1
    # rename remotes
    if git remote get-url upstream >/dev/null 2>&1; then
        git remote rename origin fork
        UPSTREAM_URL=$(git remote get-url upstream)
        UPSTREAM_OWNER=$(echo "$UPSTREAM_URL" | sed -n 's#.*github\.com[:/]\([^/]*\)/.*#\1#p')
        OLEGEASE_ORGS="olegease forkease soneight son8case son8test son8fork m20odule"
        OLEGEASE_FOUND=0
        for org in $OLEGEASE_ORGS; do
            if [ "$UPSTREAM_OWNER" = "$org" ]; then
                OLEGEASE_FOUND=1
                git remote rename upstream root
                break
            fi
        done
        if [ "$OLEGEASE_FOUND" -eq 0 ]; then
            WARNING_BEG=""
            WARNING_END=""
            if [ -t 1 ]; then
                WARNING_BEG="\033[33m"
                WARNING_END="\033[0m"
            fi

            printf "${WARNING_BEG}! upstream owner '%s' not related to a recognized organization${WARNING_END}\n" "$UPSTREAM_OWNER"
        fi
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
    printf "Error: This script requires exactly one argument\n" >&2
    printf "Usage: %s <[owner/]repo>\n" "$(basename "$0")" >&2
    exit 1
fi
# Execute
main "$1"
