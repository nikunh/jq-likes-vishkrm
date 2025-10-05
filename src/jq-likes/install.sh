#!/usr/bin/env zsh
set -e

# Logging mechanism for debugging
LOG_FILE="/tmp/jq-likes-install.log"
log_debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] $*" >> "$LOG_FILE"
}

# Initialize logging
log_debug "=== JQ-LIKES INSTALL STARTED ==="
log_debug "Script path: $0"
log_debug "PWD: $(pwd)"
log_debug "Environment: USER=$USER HOME=$HOME"

# Install jq and related JSON processing tools
echo "Installing JSON processing tools (jq, fx, yq, etc.)..."

# Set DEBIAN_FRONTEND to noninteractive
export DEBIAN_FRONTEND=noninteractive

# Get username from environment or default to babaji
USERNAME=${USERNAME:-"babaji"}
USER_HOME="/home/${USERNAME}"

# Install via package manager first
apt-get update
apt-get install -y --no-install-recommends jq

# Architecture detection
if [ "$(uname -m)" = "x86_64" ]; then
  ARCH=amd64
else
  ARCH=arm64
fi

# Install fx (JSON processing tool)
FX_VERSION="35.0.0"
FX_URL="https://github.com/antonmedv/fx/releases/download/${FX_VERSION}/fx_linux_${ARCH}"
curl -fsSL -o "/usr/local/bin/fx" "$FX_URL"
chmod +x "/usr/local/bin/fx"
echo "fx installed: $(fx --version)"

# Install yq (YAML processing)
YQ_VERSION="v4.40.5"
YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}"
curl -fsSL -o "/usr/local/bin/yq" "$YQ_URL"
chmod +x "/usr/local/bin/yq"
echo "yq installed: $(yq --version)"

# 🧩 Create Self-Healing Environment Fragment
create_environment_fragment() {
    local feature_name="json-tools"
    local fragment_file_skel="/etc/skel/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
    local fragment_file_user="$USER_HOME/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
    
    # Create fragment content with self-healing detection
    local fragment_content='# 🔧 JSON/YAML Processing Tools Environment Fragment
# Self-healing detection and environment setup

# Check if JSON/YAML tools are available
tools_available=false

# Check for individual tools and create aliases
if command -v jq >/dev/null 2>&1; then
    tools_available=true
fi

if command -v yq >/dev/null 2>&1; then
    tools_available=true
    alias yaml="yq"
fi

if command -v fx >/dev/null 2>&1; then
    tools_available=true
    alias json="fx"
fi

# Ensure /usr/local/bin is in PATH for system-wide installations
if [ -d "/usr/local/bin" ] && [[ ":$PATH:" != *":/usr/local/bin:\"* ]]; then
    export PATH="/usr/local/bin:$PATH"
    # Recheck after adding path
    for tool in jq yq fx; do
        if command -v "$tool" >/dev/null 2>&1; then
            tools_available=true
            break
        fi
    done
fi

# If no tools are available, cleanup this fragment
if [ "$tools_available" = false ]; then
    echo "JSON/YAML processing tools removed, cleaning up environment"
    rm -f "$HOME/.ohmyzsh_source_load_scripts/.json-tools.zshrc"
fi'

    # Create fragment for /etc/skel
    if [ -d "/etc/skel/.ohmyzsh_source_load_scripts" ]; then
        echo "$fragment_content" > "$fragment_file_skel"
    fi

    # Create fragment for existing user
    if [ -d "$USER_HOME/.ohmyzsh_source_load_scripts" ]; then
        echo "$fragment_content" > "$fragment_file_user"
        if [ "$USER" != "$USERNAME" ]; then
            chown ${USERNAME}:${USERNAME} "$fragment_file_user" 2>/dev/null || chown ${USERNAME}:users "$fragment_file_user" 2>/dev/null || true
        fi
    elif [ -d "$USER_HOME" ]; then
        # Create the directory if it doesn't exist
        mkdir -p "$USER_HOME/.ohmyzsh_source_load_scripts"
        echo "$fragment_content" > "$fragment_file_user"
        if [ "$USER" != "$USERNAME" ]; then
            chown -R ${USERNAME}:${USERNAME} "$USER_HOME/.ohmyzsh_source_load_scripts" 2>/dev/null || chown -R ${USERNAME}:users "$USER_HOME/.ohmyzsh_source_load_scripts" 2>/dev/null || true
        fi
    fi
    
    echo "Self-healing environment fragment created: .json-tools.zshrc"
}

# Call the fragment creation function
create_environment_fragment

echo "JSON processing tools installation completed."

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
# Example for yq (mikefarah/yq):
# YQ_VERSION="4.44.1"
# YQ_URL="https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64"
# curl -fsSL -o "$INSTALL_DIR/yq" "$YQ_URL"
# chmod +x "$INSTALL_DIR/yq"
# echo "yq installed: $($INSTALL_DIR/yq --version)"

# Example for gojq:
# GOJQ_VERSION="0.12.13"
# GOJQ_URL="https://github.com/itchyny/gojq/releases/download/v${GOJQ_VERSION}/gojq_linux_amd64"
# curl -fsSL -o "$INSTALL_DIR/gojq" "$GOJQ_URL"
# chmod +x "$INSTALL_DIR/gojq"
# echo "gojq installed: $($INSTALL_DIR/gojq --version)"

# Example for xq (requires pip):
# pip install --no-cache-dir xq

# Example for lsd:
# LSD_VERSION="1.1.2"
# LSD_URL="https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd-v${LSD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
# curl -fsSL -o /tmp/lsd.tar.gz "$LSD_URL"
# tar -xzf /tmp/lsd.tar.gz -C /tmp
# mv /tmp/lsd*/lsd "$INSTALL_DIR/lsd"
# chmod +x "$INSTALL_DIR/lsd"
# echo "lsd installed: $($INSTALL_DIR/lsd --version)"
log_debug "=== JQ-LIKES INSTALL COMPLETED ==="
# Test automation change Tue Sep 23 19:56:06 BST 2025
# Auto-trigger build Tue Sep 23 20:03:15 BST 2025
