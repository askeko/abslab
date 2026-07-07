# Abslab - Dendritic NixOS Config

An attempt at adopting the dendritic pattern with flake-parts for my NixOS multi-host configuration.

## Features

### Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) and age.
Recipients live in `.sops.yaml`: one admin key (kept **off** the hosts, e.g. in
a password manager — it is the escrow/recovery key and is only needed to edit
secrets or re-key hosts) plus one machine key per host at
`/persist/var/lib/sops-nix/key.txt`.

Two storage patterns:

- **`secrets/secrets.yaml`** — small values wired into nix options (user
  password hashes, GitHub SSH key). Edit with `just secrets-edit`.
- **Whole-file drop-in directories** — files decrypted verbatim to a path at
  activation; modules auto-discover them, so adding one needs no nix changes:

  | Directory            | Decrypted to        | Used by                          |
  | -------------------- | ------------------- | -------------------------------- |
  | `secrets/wireguard/` | `/etc/wireguard/`   | `wg-quick` via the rofi VPN menu |
  | `secrets/iwd/`       | `/var/lib/iwd/`     | iwd Wi-Fi profiles               |

Remember to `git add` new secret files — flakes only see tracked files. Never
commit a plaintext secret: encrypt first (`sops filestatus <file>` shows the
current state).

### Task runner

`just` is the task runner; recipes run inside the dev shell (`nix develop`),
which provides `just`, `sops`, `age` and the lint/format tools.

| Recipe                | Purpose                                                    |
| --------------------- | ---------------------------------------------------------- |
| `just switch`         | Build and switch to the current host configuration        |
| `just test`           | Activate without adding a boot entry (reverts on reboot)  |
| `just build`          | Build only, no activation                                  |
| `just lint`           | Run linters (statix, deadnix)                              |
| `just fmt`            | Format all nix files (nixfmt)                              |
| `just secrets-edit`   | Edit `secrets/secrets.yaml`                                |
| `just encrypt <file>` | Encrypt a secret file in place; refuses to double-encrypt |
| `just vpn-add <file>` | Import a WireGuard config into `secrets/wireguard/` (name ≤ 15 chars) |
| `just wifi-add <ssid>`| Create + encrypt an iwd Wi-Fi profile; prompts for the passphrase |
| `just updatekeys`     | Re-encrypt every secret to the current `.sops.yaml` recipients |

## Installation

A manual install from the **minimal** NixOS ISO onto an encrypted BTRFS root
(LUKS2, unlocked by a YubiKey via FIDO2 + PIN) with an ephemeral root — `/` is
wiped to a clean state every boot, and only `/persist`, `/home` and `/nix`
survive.

These steps assume the target host already exists under `modules/hosts/<host>/`.
Two paths differ only in the host config and the sops key:

- **Reformatting an existing host** — its module, `hardware-configuration.nix`
  template and `.sops.yaml` recipient are already in place. Reuse its sops host
  key: back up `/var/lib/sops-nix/key.txt` first, restore it to
  `/mnt/persist/var/lib/sops-nix/key.txt` during the install, and **skip the
  Secrets Key step** (no `.sops.yaml` edit, no `updatekeys`).
- **Adding a new host** — first scaffold `modules/hosts/<name>/` (`imports.nix`
  importing `efi`, `pc`/`laptop`, `impermanence`, …; `hardware-configuration.nix`;
  `hostname.nix`; `state-version.nix`; monitors/keyboard as needed), then add a
  fresh `&<name>` recipient to `.sops.yaml`. There is no key to reuse — follow
  the Secrets Key step as written.

### Installation Image

Write the minimal ISO to a USB stick and boot it in UEFI mode:

```sh
sudo dd bs=4M conv=fsync oflag=direct status=progress if=<path-to-image> of=/dev/sdX
```

### Keyboard Layout

```sh
loadkeys <layout>      # e.g. dk, us, eu
```

### Check UEFI

Should return `64`:

```sh
cat /sys/firmware/efi/fw_platform_size
```

### Network

Networking usually comes up automatically — check with `ip a`. For Wi-Fi, use
NetworkManager:

```sh
nmtui
```

If the ISO ships `wpa_supplicant` instead of NetworkManager:

```sh
sudo systemctl start wpa_supplicant
wpa_cli
# add_network → set_network 0 ssid "<SSID>" → set_network 0 psk "<password>" → enable_network 0
```

### Partitioning

Identify the target disk with `lsblk -f`. This **erases** it, so pick carefully.

| Partition | Size      | Type | Label       |
| --------- | --------- | ---- | ----------- |
| ESP       | 1 GiB     | EF00 | `ESP`       |
| LUKS root | remaining | 8300 | `cryptroot` |

```sh
DISK=/dev/nvme0n1          # SATA/SD = /dev/sdX; then drop the "p" in the partition names

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1025MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart cryptroot 1025MiB 100%
```

Encrypt the root partition. The passphrase set here becomes the recovery
keyslot. The device must be named `cryptroot`:

```sh
cryptsetup luksFormat --type luks2 "${DISK}p2"
cryptsetup open "${DISK}p2" cryptroot
```

Format and create the subvolumes:

```sh
mkfs.vfat -F32 -n ESP "${DISK}p1"
mkfs.btrfs -f -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/home
umount /mnt
```

Mount the layout:

```sh
mount -o subvol=root,compress=zstd,noatime    /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{nix,persist,home,boot}
mount -o subvol=nix,compress=zstd,noatime     /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/cryptroot /mnt/persist
mount -o subvol=home,compress=zstd,noatime    /dev/mapper/cryptroot /mnt/home
mount -o umask=077 "${DISK}p1" /mnt/boot
```

### Hardware Configuration

Fetch the tools and the configuration:

```sh
nix-shell -p git age sops
git clone <repo-url> /mnt/persist/nixos-config
cd /mnt/persist/nixos-config
```

The `hardware-configuration.nix` for each host already uses
`/dev/disk/by-partlabel/ESP` and `/dev/disk/by-partlabel/cryptroot`, which
match the labels set during partitioning above — no UUID substitution needed.

Verify the kernel modules in `modules/hosts/<host>/hardware-configuration.nix`
match what `nixos-generate-config` would emit for this machine:

```sh
nixos-generate-config --root /mnt --show-hardware-config
```

The following three settings are already present in the committed config but
are not emitted by `nixos-generate-config` — keep them if you ever regenerate:

```nix
boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "fido2-device=auto" ];
fileSystems."/persist".neededForBoot = true;
zramSwap.enable = true;
```

### Secrets Key

Generate the host's age key on `/persist` so it survives the root wipe:

```sh
sudo mkdir -p /mnt/persist/var/lib/sops-nix
sudo age-keygen -o /mnt/persist/var/lib/sops-nix/key.txt
sudo age-keygen -y /mnt/persist/var/lib/sops-nix/key.txt   # public recipient
sudo chmod 600 /mnt/persist/var/lib/sops-nix/key.txt
```

Add the recipient to `.sops.yaml`, then re-encrypt **all** secret files with
the admin key (`secrets.yaml` plus the whole-file secrets under
`secrets/wireguard/` and `secrets/iwd/`):

```sh
SOPS_AGE_KEY_FILE=<admin-key>.txt just updatekeys
# without just:
SOPS_AGE_KEY_FILE=<admin-key>.txt find secrets -type f \
  \( -name '*.yaml' -o -name '*.conf' -o -name '*.psk' \) -exec sops updatekeys -y {} \;
```

### Installation

```sh
nixos-install --flake .#<host>
```

It prompts for a root password, but under impermanence that imperative one is
wiped on first boot — root's (and your user's) actual password is the declarative
sops hash from `secrets.yaml`. Set anything at the prompt (or `--no-root-passwd`),
then reboot.

### First Boot

LUKS prompts for the recovery passphrase (no key enrolled yet). Enrol the
YubiKey(s) for disk unlock and the lock screen:

```sh
# Disk — run once per key
sudo systemd-cryptenroll \
  --fido2-device=auto --fido2-with-client-pin=yes --fido2-with-user-presence=yes \
  /dev/disk/by-partlabel/cryptroot

# Lock screen / login (stored in persistent /home)
mkdir -p ~/.config/Yubico
pamu2fcfg    > ~/.config/Yubico/u2f_keys     # first key
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys    # additional key
```

Activate and verify the root wipe:

```sh
sudo nixos-rebuild boot --flake .#<host>
echo wiped | sudo tee /test-impermanence
```

Reboot — boot asks for FIDO2 PIN + touch, autologin lands in Hyprland, and
`/test-impermanence` is gone.

## Theming

Declarative theming via [Stylix](https://github.com/nix-community/stylix),
driven by two values in `modules/style/theme.nix`:

```nix
flake.meta.theme.scheme = "gruvbox";   # any key from the scheme registry
flake.meta.theme.mode   = "dark";      # or "light"
```

### Scheme registry

`flake.meta.theme.schemes` (same file) is the single source of truth for colour
schemes. Each entry maps the scheme to a base16 stem per mode (consumed by
Stylix) and a LazyVim colorscheme spec (consumed by `modules/style/lazyvim.nix`) - add 
a scheme there once and every themed tool can use it. Base16 YAMLs
resolve against `pkgs.base16-schemes`, with `modules/style/schemes/<stem>.yaml`
as a local override for stems nixpkgs doesn't ship.

Most applications are themed automatically by Stylix (`autoEnable`); a few
targets are opted out and themed by their own modules instead: waybar (palette
vars in `waybar.nix`), neovim (LazyVim manages its colorscheme) and hyprlock
(`screenlock.nix`).

### Light/dark switching

The opposite polarity is built as a NixOS **specialisation**, so switching
between light and dark is an instant activation rather than a rebuild:

```sh
SUPER+SHIFT+S
```

LazyVim follows along by reading the live `stylix.polarity` and invalidating
nvim's loader cache on activation.

### Fonts

Font families and sizes live in `flake.meta.fonts` and feed both Stylix and
fontconfig.

### Wallpaper

Wallpapers are managed by **hyprpaper**, not Stylix (Stylix is fed a solid
pixel in the scheme's background colour, so its palette tracks the scheme
without pinning an image). `SUPER+b` opens a rofi picker over
`~/pictures/wallpapers`; the current choice is kept as a
`~/.local/state/theme/current-wallpaper` symlink, restored on login and read by
hyprlock so the lock screen follows the live wallpaper.

## References

Following repos have been a huge inspiration in making this, thank you!

- https://github.com/mightyiam/infra/ // Heavily inspired by this
- https://github.com/mightyiam/dendritic
- https://github.com/vic/vix
- https://github.com/Bad3r/nixos
- https://github.com/fbosch/nixos
