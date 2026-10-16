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
      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + M", app("${lib.getExe package}"), "Passwords")
      '';
    };
}
