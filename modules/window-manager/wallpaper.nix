{ config, lib, ... }:
let
  wallpaperDir = "/home/${config.flake.meta.owner.username}/pictures/wallpapers";
in
{
  flake.modules.homeManager.gui = hmArgs: {
    programs.noctalia.settings.wallpaper = {
      directory = lib.mkDefault wallpaperDir;
      default.path = lib.mkDefault "${wallpaperDir}/slick/apple-dark.jpg";
    };

    programs.yazi.keymap.mgr.prepend_keymap = [
      {
        on = [ "b" ];
        run = "shell '${lib.getExe hmArgs.config.programs.noctalia.package} msg wallpaper-set %h'";
        desc = "Set as wallpaper";
      }
    ];

    wayland.windowManager.hyprland.extraConfig = ''
      bind(mod .. " + B", cmd(ipc .. "panel-toggle wallpaper"), "Wallpaper picker")
    '';
  };
}
