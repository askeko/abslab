{ config, lib, ... }:
let
  inherit (config.flake.meta) fonts;
  # Colours rendered by Noctalia's GTK templates.
  noctaliaCss = ''@import url("noctalia.css");'';
in
{
  # Noctalia's GTK template also sets the GTK theme (adw-gtk3 or adw-gtk3-dark)
  # and the light/dark preference in dconf when the mode changes, so neither is
  # set here.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        font = {
          name = lib.mkDefault fonts.sansSerif.name;
          size = lib.mkDefault fonts.sizes.applications;
        };
        gtk3.extraCss = noctaliaCss;
        gtk4.extraCss = noctaliaCss;
      };

      home.packages = [ pkgs.adw-gtk3 ];

      programs.noctalia.settings.theme.templates.builtin_ids = [
        "gtk3"
        "gtk4"
      ];
    };
}
