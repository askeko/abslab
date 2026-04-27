{ config, ... }:
{
  flake.modules = {
    # INFO: currently broken
    # nixos.pc = {
    #   programs.wireshark.enable = true;
    #
    #   users.groups.wireshark.members = [
    #     config.flake.meta.owner.username
    #   ];
    # };
    # homeManager.gui =
    #   { pkgs, ... }:
    #   {
    #     home.packages = [ pkgs.wireshark ];
    #   };
  };
}
