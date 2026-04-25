#!/bin/sh
set -e

STATUS=$(bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
if [ -z "$STATUS" ] || [ "$STATUS" = "unauthenticated" ]; then
    bw config server https://vault.bitwarden.com
fi

# Run if password-manager-binary is not already in $PATH
if ! type bw >/dev/null 2>&1; then
    . /etc/os-release
    case "$ID" in
        endeavouros|arch)
            sudo pacman -S --noconfirm bitwarden-cli
            ;;
        *)
            echo "unsupported distro: $ID" >&2
            exit 1
        ;;
    esac
    bw login
fi

SSH_KEY="$HOME/.ssh/github_ed25519_0x2Elang"

# Exit if key already present
[ -f "$SSH_KEY" ] && exit 0

# Ensure BW_SESSION is set (vault must be unlocked)
if [ -z "$BW_SESSION" ]; then
    BW_SESSION="$(bw unlock --raw)"
    export BW_SESSION
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
bw get item "github_ed25519_0x2Elang" | grep -o '"privateKey":"[^"]*"' | cut -d'"' -f4 > "$SSH_KEY"
chmod 600 "$SSH_KEY"
ssh-keygen -y -f "$SSH_KEY" > "${SSH_KEY}.pub"

cat > "$HOME/.ssh/config" << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519_0x2Elang
EOF
chmod 600 "$HOME/.ssh/config"
