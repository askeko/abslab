# NixOS flake task runner
# Usage: just <recipe>

# List available recipes
default:
    @just --list

# Build and switch to the current host configuration
switch:
    nh os switch .

# Activate without adding a boot entry (reverts on reboot)
test:
    nh os test .

# Build only, no activation
build:
    nh os build .

# Run linters (statix, deadnix)
lint:
    statix check .
    deadnix --fail .

# Format all nix files
fmt:
    git ls-files -z '*.nix' | xargs -0 nixfmt

# Edit the main secrets file
secrets-edit:
    sops secrets/secrets.yaml

# Encrypt a secret file in place; refuses to double-encrypt
encrypt file:
    #!/usr/bin/env bash
    set -euo pipefail
    # filestatus errors on plaintext non-JSON files; only a parseable,
    # already-encrypted file prints "encrypted":true
    if sops filestatus "{{ file }}" 2>/dev/null | grep -q '"encrypted": *true'; then
        echo "already encrypted: {{ file }}" >&2
        exit 1
    fi
    sops -e -i "{{ file }}"

# Import a downloaded WireGuard .conf into secrets/wireguard/
vpn-add file:
    #!/usr/bin/env bash
    set -euo pipefail
    base="$(basename "{{ file }}")"
    name="${base%.conf}"
    if (( ${#name} > 15 )); then
        echo "'$name' is longer than 15 chars (wg-quick interface name limit)" >&2
        exit 1
    fi
    mkdir -p secrets/wireguard
    mv "{{ file }}" "secrets/wireguard/$base"
    sops -e -i "secrets/wireguard/$base"
    echo "imported secrets/wireguard/$base — remember to git add it"

# Create + encrypt an iwd Wi-Fi profile (prompts for the passphrase)
wifi-add ssid:
    #!/usr/bin/env bash
    set -euo pipefail
    read -rsp 'Wi-Fi passphrase: ' pass; echo
    if [[ "{{ ssid }}" =~ ^[A-Za-z0-9_-]+$ ]]; then
        name="{{ ssid }}"
    else
        name="=$(printf %s "{{ ssid }}" | od -A n -t x1 | tr -d ' \n')"
    fi
    mkdir -p secrets/iwd
    printf '[Security]\nPassphrase=%s\n' "$pass" > "secrets/iwd/$name.psk"
    sops -e -i "secrets/iwd/$name.psk"
    echo "created secrets/iwd/$name.psk — remember to git add it"

# Re-encrypt every secret to the current .sops.yaml recipients
updatekeys:
    find secrets -type f \( -name '*.yaml' -o -name '*.conf' -o -name '*.psk' \) \
        -exec sops updatekeys -y {} \;
