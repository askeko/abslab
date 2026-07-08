{ config, ... }:
{
  configurations.nixos.halflight.module = {
    home-manager.users.${config.flake.meta.owner.username} = {
      programs.niri.settings.outputs = {
        "eDP-1" = {
          scale = 1.0;
        };
      };
    };
  };
}
