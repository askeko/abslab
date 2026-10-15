{ config, lib, ... }:
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      # The module's privileged dumpcap is built from this package, so the GUI
      # build has to come from here (not HM) to capture without root.
      programs.wireshark = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.wireshark;
      };

      users.groups.wireshark.members = [
        config.flake.meta.owner.username
      ];
    };
}
