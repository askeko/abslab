{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.flake.meta) fonts;
in
{
  # Rosé Pine's GTK port: its GTK 3 theme, and for GTK 4 (libadwaita) its
  # stylesheet as gtk.css. GTK 3 keeps the default (light) preference, as the
  # port asks; color-scheme in dconf says dark, which libadwaita, Firefox and
  # Obsidian follow.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        font = {
          name = lib.mkDefault fonts.sansSerif.name;
          size = lib.mkDefault fonts.sizes.applications;
        };
        theme = {
          name = lib.mkDefault "rose-pine-gtk";
          package = lib.mkDefault (
            pkgs.linkFarm "rose-pine-gtk" {
              "share/themes/rose-pine-gtk" = "${inputs.rose-pine-gtk}/gtk3/rose-pine-gtk";
            }
          );
        };
        gtk4 = {
          theme = null;
          extraCss = builtins.readFile "${inputs.rose-pine-gtk}/gtk4/rose-pine.css";
        };
      };

      dconf.settings."org/gnome/desktop/interface".color-scheme = lib.mkDefault "prefer-dark";
    };
}
