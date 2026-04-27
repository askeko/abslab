{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      package = pkgs.rofi-rbw-wayland;
    in
    {
      home.packages = [ package ];
      xdg.configFile."rofi-rbw.rc".text = lib.generators.toINIWithGlobalSection { } {
        globalSection = { };
      };
      wayland.windowManager.hyprland.settings.bind = [
        "SUPER, m, exec, ${lib.getExe package}"
      ];
    };
}
