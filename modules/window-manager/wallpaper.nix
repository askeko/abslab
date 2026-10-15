{ config, lib, ... }:
let
  wallpaperDir = config.flake.meta.theme.wallpaper.path;
in
{
  flake.modules.homeManager.gui = hmArgs: {
    programs.noctalia.settings.wallpaper = {
      directory = lib.mkDefault wallpaperDir;
      default.path = lib.mkDefault "${wallpaperDir}/slick/apple-dark.jpg";
    };

    programs.niri.settings.binds."Mod+B".action.spawn = [
      (lib.getExe hmArgs.config.programs.noctalia.package)
      "msg"
      "panel-toggle"
      "wallpaper"
    ];
  };
}
