{ config, lib, ... }:
let
  inherit (config.flake.meta) fonts;
  qtFont = name: ''"${name},${toString fonts.sizes.applications}"'';
in
{
  # qt6ct with the Fusion style and the palette rendered by Noctalia's Qt template.
  flake.modules.homeManager.gui = hmArgs: {
    qt = {
      enable = true;
      platformTheme.name = lib.mkDefault "qtct";
      qt6ctSettings = {
        Appearance = {
          style = lib.mkDefault "Fusion";
          custom_palette = lib.mkDefault true;
          color_scheme_path = lib.mkDefault "${hmArgs.config.xdg.configHome}/qt6ct/colors/noctalia.conf";
          standard_dialogs = lib.mkDefault "default";
        };
        Fonts = {
          general = lib.mkDefault (qtFont fonts.sansSerif.name);
          fixed = lib.mkDefault (qtFont fonts.monospace.name);
        };
      };
    };

    programs.noctalia.settings.theme.templates.builtin_ids = [ "qt" ];
  };
}
