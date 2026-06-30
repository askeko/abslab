{ inputs, ... }:
{
  # Import per host only after it's reinstalled with the btrfs subvolumes below.
  flake.modules.nixos.impermanence =
    { pkgs, ... }:
    {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      # usbhid: YubiKey readable at the FIDO2 LUKS unlock prompt.
      boot.initrd.availableKernelModules = [ "usbhid" ];

      # Each boot: move the old root subvol to /old_roots (pruned after 7 days),
      # create a fresh empty one. Runs in the systemd initrd before root mounts;
      # expects the unlocked LUKS device at /dev/mapper/cryptroot.
      boot.initrd.systemd.services.rollback = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        wantedBy = [ "initrd.target" ];
        after = [ "initrd-root-device.target" ];
        requires = [ "initrd-root-device.target" ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        path = [ pkgs.btrfs-progs ];
        script = ''
          mkdir -p /btrfs_tmp
          mount -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp

          if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
            delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/root
          umount /btrfs_tmp
        '';
      };

      # /home and /nix are separate persistent subvolumes, so they survive unlisted.
      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/rfkill"
          "/var/lib/bluetooth"
          "/var/lib/iwd"
          "/var/db/sudo"
        ];
        files = [ "/etc/machine-id" ];
      };

      # Generate SSH host keys on /persist so they survive wipes once openssh is on.
      services.openssh.hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];

      sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
    };
}
