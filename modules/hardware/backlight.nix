{ lib, ... }:
{
  flake.modules.homeManager.laptop =
    { pkgs, ... }:
    let
      bright = lib.getExe pkgs.brightnessctl;
    in
    {
      home.packages = with pkgs; [
        brightnessctl
      ];
      programs.niri.settings.binds = {
        "XF86MonBrightnessUp" = {
          action.spawn = [
            bright
            "set"
            "+10%"
          ];
          allow-when-locked = true;
        };
        "XF86MonBrightnessDown" = {
          action.spawn = [
            bright
            "set"
            "10%-"
          ];
          allow-when-locked = true;
        };
      };
    };
}
