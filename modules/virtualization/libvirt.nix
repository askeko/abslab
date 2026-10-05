{ config, ... }:
{
  # KVM/QEMU via libvirt, managed from virt-manager (e.g. Kali guest).
  flake.modules.nixos.pc =
    { lib, ... }:
    {
      virtualisation.libvirtd = {
        enable = lib.mkDefault true;
        qemu.swtpm.enable = lib.mkDefault true;
      };
      virtualisation.spiceUSBRedirection.enable = lib.mkDefault true;
      programs.virt-manager.enable = lib.mkDefault true;

      users.users.${config.flake.meta.owner.username}.extraGroups = [ "libvirtd" ];
    };

  flake.modules.homeManager.gui = {
    # Auto-connect virt-manager to the system daemon instead of prompting.
    dconf.settings."org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
