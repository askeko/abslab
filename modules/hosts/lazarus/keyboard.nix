{ config, ... }:
{
  configurations.nixos.lazarus.module = {
    services.xserver.xkb.layout = "eu";
    home-manager.users.${config.flake.meta.owner.username} = {
      programs.niri.settings.input.keyboard.xkb.layout = "eu";
    };
  };
}
