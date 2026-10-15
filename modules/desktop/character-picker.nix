{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      inherit (pkgs) rofimoji;
    in
    {
      home.packages = [ rofimoji ];

      programs.niri.settings.binds = {
        "Mod+U".action.spawn = [
          (lib.getExe hmArgs.config.programs.noctalia.package)
          "msg"
          "panel-toggle"
          "launcher"
          "/emo"
        ];
        "Mod+Shift+U".action.spawn = [
          (lib.getExe rofimoji)
          "--files"
          "all"
        ];
      };
    };
}
