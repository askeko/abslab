{ config, ... }:
{
  configurations.nixos.halflight.module = {
    services.xserver.xkb = {
      layout = "dk";
      options = "caps:swapescape";
    };
    home-manager.users.${config.flake.meta.owner.username} = {
      programs.niri.settings.input.keyboard.xkb = {
        layout = "dk";
        options = "caps:swapescape";
      };
    };
  };
}
