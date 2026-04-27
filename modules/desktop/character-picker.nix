{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      inherit (pkgs) rofimoji;
    in
    {
      home.packages = [ rofimoji ];

      wayland.windowManager.hyprland.settings.bind = [
        "SUPER, u, exec, ${lib.getExe rofimoji}"
        "SUPER+SHIFT, u, exec, ${lib.getExe rofimoji} --files all"
      ];
    };
}
