{ config, lib, ... }:
let
  inherit (config.flake.meta) fonts;
  qtFont = name: ''"${name},${toString fonts.sizes.applications}"'';
in
{
  # Qt 5 and 6 share the Fusion style and Noctalia's generated palette.
  flake.modules.homeManager.gui =
    hmArgs:
    let
      qtctSettings = qtct: {
        Appearance = {
          style = lib.mkDefault "Fusion";
          custom_palette = lib.mkDefault true;
          color_scheme_path = lib.mkDefault "${hmArgs.config.xdg.configHome}/${qtct}/colors/noctalia.conf";
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
        qt5ctSettings = qtctSettings "qt5ct";
        qt6ctSettings = qtctSettings "qt6ct";
      };

      programs.noctalia.settings.theme.templates.builtin_ids = [ "qt" ];
    };
}
