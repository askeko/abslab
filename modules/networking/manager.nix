{ config, ... }:
{
  flake.modules.nixos.pc = {
    networking.networkmanager.enable = true;
    users.users.${config.flake.meta.owner.username}.extraGroups = [ "networkmanager" ];
  };
}
