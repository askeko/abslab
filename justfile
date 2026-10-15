# NixOS flake task runner
# Usage: just <recipe>

# sops reads the admin age key from Bitwarden via rbw instead of a key file
export SOPS_AGE_KEY_CMD := env_var_or_default("SOPS_AGE_KEY_CMD", "rbw get 'sops admin key'")

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

# Re-encrypt every secret to the current .sops.yaml recipients
updatekeys:
    find secrets -type f \( -name '*.yaml' -o -name '*.conf' -o -name '*.psk' \) \
        -exec sops updatekeys -y {} \;
