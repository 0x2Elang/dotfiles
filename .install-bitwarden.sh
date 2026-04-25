#!/bin/sh
set -e

# Set US server (idempotent, bw config server is safe to re-run)
STATUS=$(bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
if [ -z "$STATUS" ] || [ "$STATUS" = "unauthenticated" ]; then
    bw config server https://vault.bitwarden.com
fi

# exit immediately if password-manager-binary is already in $PATH
type bw >/dev/null 2>&1 && exit

case "$(uname -s)" in
Linux)
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
   ;;
*)
    echo "unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

bw login
