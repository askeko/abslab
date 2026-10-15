{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    {
      home.packages = with pkgs; [
        wl-clipboard-rs
      ];

      programs.niri.settings.binds."Mod+P".action.spawn = [
        (lib.getExe hmArgs.config.programs.noctalia.package)
        "msg"
        "panel-toggle"
        "clipboard"
      ];
    };
}
