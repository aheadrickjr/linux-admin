# filename: scripts/40_git_pat_setup.sh
#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "        Git HTTPS + PAT Setup         "
echo "======================================"

if ! command -v git >/dev/null 2>&1; then
    echo "Git is not installed. Run 10_base_host_build.sh first."
    exit 1
fi

read -rp "Enter local destination directory (example: /home/howard/repos/linux-build): " DEST_DIR
if [[ -z "${DEST_DIR:-}" ]]; then
    echo "Destination directory is required."
    exit 1
fi

read -rp "Enter GitHub repo HTTPS URL (example: https://github.com/aheadrickjr/linux-build.git): " REPO_URL
if [[ -z "${REPO_URL:-}" ]]; then
    echo "Repository URL is required."
    exit 1
fi

read -rp "Enter GitHub username: " GIT_USERNAME
if [[ -z "${GIT_USERNAME:-}" ]]; then
    echo "GitHub username is required."
    exit 1
fi

read -rsp "Enter GitHub PAT (hidden): " GIT_PAT
echo
if [[ -z "${GIT_PAT:-}" ]]; then
    echo "PAT is required."
    exit 1
fi

AUTH_HEADER="$(printf "%s:%s" "$GIT_USERNAME" "$GIT_PAT" | base64 | tr -d '\n')"

mkdir -p "$(dirname "$DEST_DIR")"

if [[ -d "$DEST_DIR/.git" ]]; then
    echo "[+] Existing Git repository detected at $DEST_DIR"
    echo "[+] Fetching latest changes..."
    git -C "$DEST_DIR" -c http.extraHeader="Authorization: Basic $AUTH_HEADER" fetch --all --prune

    CURRENT_BRANCH="$(git -C "$DEST_DIR" branch --show-current || true)"
    if [[ -n "${CURRENT_BRANCH:-}" ]]; then
        echo "[+] Pulling current branch: $CURRENT_BRANCH"
        git -C "$DEST_DIR" -c http.extraHeader="Authorization: Basic $AUTH_HEADER" pull origin "$CURRENT_BRANCH"
    else
        echo "[!] Could not detect current branch. Fetch completed only."
    fi
else
    echo "[+] Cloning repository into $DEST_DIR ..."
    git -c http.extraHeader="Authorization: Basic $AUTH_HEADER" clone "$REPO_URL" "$DEST_DIR"
fi

unset GIT_PAT
unset AUTH_HEADER

echo
echo "======================================"
echo "         Git PAT Workflow Done        "
echo "======================================"
echo "Destination: $DEST_DIR"
