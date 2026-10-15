{ lib, ... }:
{
  flake.modules.homeManager.laptop =
    hmArgs@{ pkgs, ... }:
    let
      # Fn keys stay usable on the lock screen
      brightness = direction: {
        action.spawn = [
          (lib.getExe hmArgs.config.programs.noctalia.package)
          "msg"
          "brightness-${direction}"
        ];
        allow-when-locked = true;
      };
    in
    {
      home.packages = with pkgs; [
        brightnessctl
      ];
      programs.niri.settings.binds = {
        "XF86MonBrightnessUp" = brightness "up";
        "XF86MonBrightnessDown" = brightness "down";
      };
    };
}
