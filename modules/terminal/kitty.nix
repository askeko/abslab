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
      # Rosé Pine's kitty port, as shipped in kitty-themes.
      themeFile = lib.mkDefault "rose-pine";

      font = {
        name = lib.mkDefault fonts.monospace.name;
        size = lib.mkDefault fonts.sizes.terminal;
      };

      settings = {
        window_padding_width = lib.mkDefault 5;
        enable_audio_bell = lib.mkDefault "no";
      };
    };
  };
}
