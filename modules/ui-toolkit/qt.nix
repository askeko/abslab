{ config, lib, ... }:
let
  inherit (config.flake.meta) fonts;
  qtFont = name: ''"${name},${toString fonts.sizes.applications}"'';
in
{
  # Qt 5 and 6: Rosé Pine's Kvantum port (iris accent, as its GTK 4 port),
  # with qtct for fonts.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      qtctSettings = {
        Appearance = {
          style = lib.mkDefault "kvantum";
          custom_palette = lib.mkDefault false;
          standard_dialogs = lib.mkDefault "default";
        };
        Fonts = {
          general = lib.mkDefault (qtFont fonts.sansSerif.name);
          fixed = lib.mkDefault (qtFont fonts.monospace.name);
        };
      };
    in
    {
      qt = {
        enable = true;
        platformTheme.name = lib.mkDefault "qtct";
        style.name = lib.mkDefault "kvantum";
        qt5ctSettings = qtctSettings;
        qt6ctSettings = qtctSettings;
        kvantum = {
          enable = true;
          settings.General.theme = lib.mkDefault "rose-pine-iris";
        };
      };

      # Kvantum looks for Kvantum/<theme>/; nixpkgs' rose-pine-kvantum has its
      # themes one level deeper, so qt.kvantum.themes would miss them.
      xdg.configFile."Kvantum/rose-pine-iris".source =
        "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-iris";
    };
}
