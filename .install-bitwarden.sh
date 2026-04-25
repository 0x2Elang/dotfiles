#!/bin/sh
set -e

# Set EU server (idempotent — bw config server is safe to re-run)
bw config server https://vault.bitwarden.com

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
