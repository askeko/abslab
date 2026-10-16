{ config, lib, ... }:
let
  wallpaperDir = "/home/${config.flake.meta.owner.username}/pictures/wallpapers";
in
{
  flake.modules.homeManager.gui = {
    programs.noctalia.settings.wallpaper = {
      directory = lib.mkDefault wallpaperDir;
      default.path = lib.mkDefault "${wallpaperDir}/slick/apple-dark.jpg";
    };

    wayland.windowManager.hyprland.extraConfig = ''
      bind(mod .. " + B", cmd(ipc .. "panel-toggle wallpaper"), "Wallpaper picker")
    '';
  };
}
