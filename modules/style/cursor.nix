{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      # Only the cursor theme out of KDE's breeze, whose full closure is ~1.8 GiB.
      breeze-cursors = pkgs.runCommand "breeze-cursors" { } ''
        mkdir -p $out/share/icons
        cp -r ${pkgs.kdePackages.breeze}/share/icons/breeze_cursors $out/share/icons/
      '';
    in
    {
      home.pointerCursor = {
        enable = lib.mkDefault true;
        package = lib.mkDefault breeze-cursors;
        name = lib.mkDefault "breeze_cursors";
        size = lib.mkDefault 24;
        gtk.enable = lib.mkDefault true;
      };
    };
}
