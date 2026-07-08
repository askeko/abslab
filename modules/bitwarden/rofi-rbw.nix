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
      programs.niri.settings.binds."Mod+M".action.spawn = lib.getExe package;
    };
}
