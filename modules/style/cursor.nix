{ lib, ... }:
{
  # Rosé Pine's cursor port.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.pointerCursor = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.rose-pine-cursor;
        name = lib.mkDefault "BreezeX-RosePine-Linux";
        size = lib.mkDefault 24;
        gtk.enable = lib.mkDefault true;
      };
    };
}
