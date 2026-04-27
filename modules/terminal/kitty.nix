{ lib, ... }:
{
  flake.modules.homeManager.gui = hmArgs: {
    terminal = {
      path = lib.getExe hmArgs.config.programs.kitty.package;
      desktopFileId = "Kitty.desktop";
    };

    programs.kitty = {
      enable = true;

      settings = {
        window_padding_width = 5;
        enable_audio_bell = "no";
      };
    };
  };
}
