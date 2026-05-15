{
  configurations.nixos.lazarus.module = {
    # Second SSD (NTFS)
    # Get the UUID with: lsblk -f
    fileSystems."/mnt/data" = {
      device = "/dev/disk/by-uuid/5672622A72620F55";
      fsType = "ntfs-3g";
      options = [
        "rw" # Read/write access
        "uid=1000" # Owner is your user
        "gid=100" # Group is 'users'
        "dmask=022" # Directory permissions: 755
        "fmask=022" # File permissions: 755
        "nofail" # Don't block boot if the drive is missing
      ];
    };
  };
}
