# Abslab - Dendritic NixOS Config

An attempt at adopting the dendritic pattern with flake-parts for my NixOS multi-host configuration.

## Features



## Installation

A manual install from the **minimal** NixOS ISO onto an encrypted BTRFS root
(LUKS2, unlocked by a YubiKey via FIDO2 + PIN) with an ephemeral root — `/` is
wiped to a clean state every boot, and only `/persist`, `/home` and `/nix`
survive.

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

| Partition | Size      | Type | Name        |
| --------- | --------- | ---- | ----------- |
| ESP       | 1 GiB     | EF00 | `boot`      |
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
mkfs.vfat -F32 -n boot "${DISK}p1"
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

Generate the hardware config and merge `fileSystems`,
`boot.initrd.luks.devices` and the kernel modules into
`modules/hosts/<host>/hardware-configuration.nix`:

```sh
nixos-generate-config --root /mnt --show-hardware-config
```

Then add the three things it can't detect:

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

Add the recipient to `.sops.yaml`, then re-encrypt with the admin key:

```sh
SOPS_AGE_KEY_FILE=<admin-key>.txt sops updatekeys secrets/secrets.yaml
```

### Installation

```sh
nixos-install --flake .#<host>
```

Set the root password when prompted, then reboot.

### First Boot

LUKS prompts for the recovery passphrase (no key enrolled yet). Enrol the
YubiKey(s) for disk unlock and the lock screen:

```sh
# Disk — run once per key
sudo systemd-cryptenroll \
  --fido2-device=auto --fido2-with-client-pin=yes --fido2-with-user-presence=yes \
  /dev/disk/by-uuid/<luks-partition-uuid>

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



## References

Following repos have been a huge inspiration in making this, thank you!

- https://github.com/mightyiam/infra/ // Heavily inspired by this
- https://github.com/mightyiam/dendritic
- https://github.com/vic/vix
- https://github.com/Bad3r/nixos
- https://github.com/fbosch/nixos
