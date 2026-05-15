{ config, ... }:
{
  configurations.nixos.halflight.module = {
    services.xserver.xkb = {
      layout = "dk";
      options = "caps:swapescape";
    };
    home-manager.users.${config.flake.meta.owner.username} = {
      wayland.windowManager.hyprland.settings.input = {
        kb_layout = "dk";
        kb_options = "caps:swapescape";
      };
    };
  };
}
