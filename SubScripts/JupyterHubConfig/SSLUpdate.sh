#!/bin/bash

set -euo pipefail

# --- Configuration ---
CERT_DIR="ssl"
CERT_NAME="sctraingcourse.engin.umd.umich.edu"
NEW_CERT_FILE="${CERT_DIR}/${CERT_NAME}.cert"
NEW_KEY_FILE="${CERT_DIR}/${CERT_NAME}.key"
BACKUP_DIR="${CERT_DIR}/ssl.old"
SECRET_NAME="jupyter-tls"
NAMESPACE="jupyter-hub"


# --- Helper Functions ---

# Check for required command-line tools
check_deps() {
    for cmd in kubectl openssl cmp date base64; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: Required command '$cmd' not found. Please install it and try again."
            exit 1
        fi
    done
}

# Prompts the user to paste multi-line content
prompt_for_paste() {
    local prompt_message=$1
    echo "$prompt_message"
    echo "Paste the content, then press Ctrl+D on a new line to finish."
    cat
}

# Validates PEM content (certificate or key) using openssl
# $1: content to validate
# $2: type ("x509" for cert, "rsa" for key)
validate_pem() {
    local content=$1
    local type=$2
    echo "$content" | openssl "$type" -noout -text &>/dev/null
}

# Gets the expiration date of a certificate file in seconds since epoch
get_cert_expiry_date() {
    local cert_file=$1
    if [ ! -f "$cert_file" ]; then return 1; fi
    date -d "$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)" +%s
}

# Fetches a component (cert or key) from the Kubernetes secret
# $1: component ("tls.crt" or "tls.key")
# $2: temporary file path to write to
get_from_secret() {
    local component=$1
    local tmp_file=$2
    if ! kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath="{.data.${component}}" &>/dev/null; then
        return 1
    fi
    kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath="{.data.${component}}" | base64 --decode > "$tmp_file"
}

# --- Main Script Logic ---

# Cleanup trap for temporary files
cleanup() {
    rm -f /tmp/secret_cert_*.pem /tmp/secret_key_*.pem /tmp/pasted_cert_*.pem
}
trap cleanup EXIT

check_deps
echo "Starting SSL certificate update process..."

# --- Step 1: Ensure local files and directories exist ---
mkdir -p "$CERT_DIR" "$BACKUP_DIR"

# Handle Key File
if [ ! -f "$NEW_KEY_FILE" ]; then
    echo "Key file '$NEW_KEY_FILE' not found."
    while true; do
        pasted_key=$(prompt_for_paste "Please paste the private key content:")
        if validate_pem "$pasted_key" "rsa"; then
            echo "$pasted_key" > "$NEW_KEY_FILE"
            chmod 600 "$NEW_KEY_FILE"
            echo "Key file created successfully."
            break
        else
            echo "Error: Invalid key format. Please try again."
        fi
    done
fi

# Handle Certificate File
if [ ! -f "$NEW_CERT_FILE" ]; then
    echo "Certificate file '$NEW_CERT_FILE' not found."
    while true; do
        pasted_cert=$(prompt_for_paste "Please paste the certificate content:")
        if [ -n "$pasted_cert" ] && validate_pem "$pasted_cert" "x509"; then # Ensure not empty and valid
            echo "$pasted_cert" > "$NEW_CERT_FILE"
            echo "Certificate file created successfully."
            break
        else
            echo "Error: Invalid certificate format. Please try again."
        fi
    done
fi

# --- Step 2: Check Kubernetes Secret and Backup ---
TMP_SECRET_CERT=$(mktemp /tmp/secret_cert_XXXXXX.pem)
if ! get_from_secret 'tls\.crt' "$TMP_SECRET_CERT"; then
    echo "No existing secret '$SECRET_NAME' found. This will be a new installation."
else
    echo "Found existing secret '$SECRET_NAME'. Checking for backup..."
    is_backed_up=false
    shopt -s nullglob
    for old_cert in "$BACKUP_DIR"/*.cert.*; do
        if cmp -s "$TMP_SECRET_CERT" "$old_cert"; then
            is_backed_up=true
            break
        fi
    done
    shopt -u nullglob

    if [ "$is_backed_up" = true ]; then
        echo "Current secret is already backed up. Skipping."
    else
        echo "Backing up current certificate from secret..."
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        BACKUP_CERT_FILE="${BACKUP_DIR}/${CERT_NAME}.cert.${TIMESTAMP}.bak"
        BACKUP_KEY_FILE="${BACKUP_DIR}/${CERT_NAME}.key.${TIMESTAMP}.bak"
        
        cp "$TMP_SECRET_CERT" "$BACKUP_CERT_FILE"
        if get_from_secret 'tls\.key' "$TMP_SECRET_KEY"; then
            cp "$TMP_SECRET_KEY" "$BACKUP_KEY_FILE"
        else
            echo "Warning: Could not retrieve key from secret. Backup might be incomplete."
        fi
        echo "Backup created in '$BACKUP_DIR'."
    fi
fi

# --- Step 3: Compare Local Cert with Secret Cert and Update Local if Needed ---
if [ -s "$TMP_SECRET_CERT" ]; then # Only run this block if a secret existed
    if cmp -s "$NEW_CERT_FILE" "$TMP_SECRET_CERT"; then
        echo "The local certificate file is identical to the one in the secret."
        while true; do
            pasted_cert=$(prompt_for_paste "Please paste the NEW certificate content to update:")
            if [ -z "$pasted_cert" ]; then
                echo "Empty certificate pasted. Using the existing certificate in '$NEW_CERT_FILE'."
                break
            elif validate_pem "$pasted_cert" "x509"; then
                echo "$pasted_cert" > "$NEW_CERT_FILE"
                echo "Local certificate file has been updated."
                break
            else
                echo "Error: Invalid certificate format. Using the existing certificate in '$NEW_CERT_FILE'."
                break
            fi
        done
    else
        echo "Local certificate file differs from the secret. Checking expiration dates..."
        local_expiry=$(get_cert_expiry_date "$NEW_CERT_FILE")
        secret_expiry=$(get_cert_expiry_date "$TMP_SECRET_CERT")

        echo "Local cert expires: $(date -d @$local_expiry)"
        echo "Secret cert expires: $(date -d @$secret_expiry)"

        if [ "$local_expiry" -le "$secret_expiry" ]; then
            echo "The local certificate does not expire after the one in the secret."
            while true; do
                pasted_cert=$(prompt_for_paste "Please paste a NEWER certificate content to update:")
                TMP_PASTED_CERT=$(mktemp /tmp/pasted_cert_XXXXXX.pem)
                echo "$pasted_cert" > "$TMP_PASTED_CERT"
                if [ -z "$pasted_cert" ]; then
                    echo "Empty certificate pasted. Using the existing certificate in '$NEW_CERT_FILE'."
                    break
                elif validate_pem "$pasted_cert" "x509"; then
                    pasted_expiry=$(get_cert_expiry_date "$TMP_PASTED_CERT")
                    if [ "$pasted_expiry" -gt "$secret_expiry" ]; then
                        echo "$pasted_cert" > "$NEW_CERT_FILE"
                        echo "Local certificate file has been updated with a newer certificate."
                        break
                    else
                        echo "Error: The pasted certificate is not newer than the one in the secret. Please paste a different one."
                    fi
                else
                    echo "Error: Invalid certificate format. Using the existing certificate in '$NEW_CERT_FILE'."
                    break
                fi
            done
        else
            echo "Local certificate is newer. It will be used for the update."
        fi
    fi
fi

# --- Step 4: Final Validation and Update ---
echo "Validating final certificate and key pair..."

USE_FALLBACK_CERT_FILE=""
USE_FALLBACK_KEY_FILE=""

# Check if local files are valid and match
if openssl x509 -noout -modulus -in "$NEW_CERT_FILE" &>/dev/null && \
   openssl rsa -noout -modulus -in "$NEW_KEY_FILE" &>/dev/null; then
    cert_mod=$(openssl x509 -noout -modulus -in "$NEW_CERT_FILE" | openssl md5)
    key_mod=$(openssl rsa -noout -modulus -in "$NEW_KEY_FILE" | openssl md5)

    if [ "$cert_mod" != "$key_mod" ]; then
        echo "WARNING: The certificate in '$NEW_CERT_FILE' and the key in '$NEW_KEY_FILE' do not match."
        # Fallback only if a secret existed to fall back to
        if [ -s "$TMP_SECRET_CERT" ] && [ -s "$TMP_SECRET_KEY" ]; then
            echo "Falling back to the existing certificate and key from Kubernetes secret for the update."
            USE_FALLBACK_CERT_FILE="$TMP_SECRET_CERT"
            USE_FALLBACK_KEY_FILE="$TMP_SECRET_KEY"
        else
            echo "FATAL ERROR: No existing secret found to fall back to. Cannot proceed with mismatched local files."
            exit 1
        fi
    else
        echo "Certificate and key pair match. Using local files for update."
    fi
else
    echo "WARNING: Local certificate or key file is invalid."
    # Fallback only if a secret existed to fall back to
    if [ -s "$TMP_SECRET_CERT" ] && [ -s "$TMP_SECRET_KEY" ]; then
        echo "Falling back to the existing certificate and key from Kubernetes secret for the update."
        USE_FALLBACK_CERT_FILE="$TMP_SECRET_CERT"
        USE_FALLBACK_KEY_FILE="$TMP_SECRET_KEY"
    else
        echo "FATAL ERROR: No existing secret found to fall back to. Cannot proceed with invalid local files."
        exit 1
    fi
fi

# Determine which files to use for kubectl apply
CERT_TO_USE="${USE_FALLBACK_CERT_FILE:-$NEW_CERT_FILE}"
KEY_TO_USE="${USE_FALLBACK_KEY_FILE:-$NEW_KEY_FILE}"

# --- Step 5: Update Kubernetes and Restart ---
echo "Updating SSL Certificate in Kubernetes using '$CERT_TO_USE' and '$KEY_TO_USE'..."
kubectl create secret tls "$SECRET_NAME" \
  --key="$KEY_TO_USE" \
  --cert="$CERT_TO_USE" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret '$SECRET_NAME' has been updated."

echo "Restarting JupyterHub Proxy and Hub to apply the new certificate..."
kubectl rollout restart deployment.apps/proxy -n "$NAMESPACE"
kubectl rollout restart deployment.apps/hub -n "$NAMESPACE"

echo "SSL certificate update process completed successfully."