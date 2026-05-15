{ config, ... }:
{
  configurations.nixos.lazarus.module = {
    services.xserver.xkb.layout = "eu";
    home-manager.users.${config.flake.meta.owner.username} = {
      wayland.windowManager.hyprland.settings.input = {
        kb_layout = "eu";
      };
    };
  };
}
