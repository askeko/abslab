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
      wayland.windowManager.hyprland.settings.bind = [
        ",XF86MonBrightnessUp, exec, ${bright} set +10%"
        ",XF86MonBrightnessDown, exec, ${bright} set 10%-"
      ];
    };
}
