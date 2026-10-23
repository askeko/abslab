{ config, lib, ... }:
let
  inherit (config.flake.meta) fonts;
in
{
  flake.modules.homeManager.gui = hmArgs: {
    terminal = {
      path = lib.getExe hmArgs.config.programs.kitty.package;
      desktopFileId = "Kitty.desktop";
    };

    programs.kitty = {
      enable = true;

      font = {
        name = lib.mkDefault fonts.monospace.name;
        size = lib.mkDefault fonts.sizes.terminal;
      };

      settings = {
        window_padding_width = lib.mkDefault 5;
        enable_audio_bell = lib.mkDefault "no";
      };

      # Colours rendered by Noctalia's kitty template.
      extraConfig = "include themes/noctalia.conf";
    };

    programs.noctalia.settings.theme.templates.builtin_ids = [ "kitty" ];
  };
}
