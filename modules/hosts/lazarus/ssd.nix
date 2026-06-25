{ config, ... }:
let
  owner = config.flake.meta.owner.username;
in
{
  configurations.nixos.lazarus.module =
    { config, ... }:
    {
      # Second SSD (NTFS)
      # Get the UUID with: lsblk -f
      fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/5672622A72620F55";
        fsType = "ntfs-3g";
        options = [
          "rw" # Read/write access
          "uid=${toString config.users.users.${owner}.uid}" # Owner is the flake owner
          "gid=${toString config.users.groups.users.gid}" # Group is 'users'
          "dmask=022" # Directory permissions: 755
          "fmask=022" # File permissions: 755
          "nofail" # Don't block boot if the drive is missing
        ];
      };
    };
}
