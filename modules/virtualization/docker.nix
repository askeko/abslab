{ lib, ... }:
{
  flake.modules.nixos.pc = {
    virtualisation.docker = {
      enable = lib.mkDefault true;
      daemon.settings = {
        default-address-pools = lib.mkDefault [
          {
            base = "10.200.0.0/16";
            size = 24;
          }
        ];
      };
    };
  };
}
