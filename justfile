# NixOS flake task runner
# Usage: just <recipe>

# List available recipes
default:
    @just --list

# Build and switch to the current host configuration
switch:
    nh os switch

# Build without switching (dry run)
build:
    nh os test

# Run linter (statix, deadnix, treefmt, actionlint, shellcheck)
lint:
    nix run .#lint

# Format all files
fmt:
    nix run .#fmt
