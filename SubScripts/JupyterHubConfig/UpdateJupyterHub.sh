#!/bin/bash
set -euo pipefail

# --- Helper Function ---

# Downloads a file and replaces the local version only if it's different.
# Reports whether the file was changed.
#
# Usage: update_file_if_changed "filename" "url" ["executable"]
#
# $1: The local filename.
# $2: The URL to download from.
# $3: (optional) A non-empty string (e.g., "executable") to make the file executable.
update_file_if_changed() {
    local filename="$1"
    local url="$2"
    local is_executable="${3:-}"
    local tmp_file
    
    # Create a temporary file in the current directory to handle potential mv cross-device issues
    tmp_file=$(mktemp ./"${filename}.XXXXXX")
    # Ensure temp file is cleaned up on exit or error
    trap 'rm -f "$tmp_file"' RETURN

    echo "Checking for updates for '$filename'..."
    
    # Download the file with cache-busting headers, following redirects (-L)
    if ! curl -s -H 'Cache-Control: no-cache, no-store' -L -o "$tmp_file" "$url"; then
        echo "Error: Failed to download '$filename' from '$url'. Aborting."
        return 1 # set -e will cause script to exit
    fi

    # Check if the downloaded file is empty, which indicates a problem
    if [ ! -s "$tmp_file" ]; then
        echo "Error: Downloaded file '$filename' is empty. Aborting."
        return 1 # set -e will cause script to exit
    fi

    if [ ! -f "$filename" ]; then
        echo " -> New file. '$filename' has been created."
        mv "$tmp_file" "$filename"
    elif ! cmp -s "$filename" "$tmp_file"; then
        echo " -> Found a new version. '$filename' has been updated."
        mv "$tmp_file" "$filename"
    else
        echo " -> '$filename' is already up to date."
    fi

    if [ -n "$is_executable" ]; then
        chmod +x "$filename" || { echo "Error: Failed to set execute permissions on '$filename'. Aborting."; return 1; }
    fi
}

# --- Main Script ---

BASE_URL="https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig"

update_file_if_changed "config.yaml" "${BASE_URL}/config.yaml"
update_file_if_changed "monitorJupyterHub.sh" "${BASE_URL}/monitorJupyterHub.sh" "executable"
update_file_if_changed "SSLUpdate.sh" "${BASE_URL}/SSLUpdate.sh" "executable"

echo "" # Add a newline for better readability

echo "Updating JupyterHub Helm release..."
helm upgrade --cleanup-on-fail \
  jupyterhub jupyterhub/jupyterhub \
  --namespace jupyter-hub \
  --version=3.3.0 \
  --timeout 10m0s \
  --values config.yaml \
  || { echo "Error: Helm upgrade failed. Please check the output above for details. Aborting."; exit 1; }
echo "JupyterHub updated successfully via Helm."
echo ""

# Self-update this script last
update_file_if_changed "UpdateJupyterHub.sh" "${BASE_URL}/UpdateJupyterHub.sh" "executable"

echo ""
echo "All updates completed."