{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      inherit (pkgs) rofimoji;
    in
    {
      home.packages = [ rofimoji ];

      programs.niri.settings.binds = {
        "Mod+U".action.spawn = lib.getExe rofimoji;
        "Mod+Shift+U".action.spawn = [
          (lib.getExe rofimoji)
          "--files"
          "all"
        ];
      };
    };
}
