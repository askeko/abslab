{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    {
      options.terminal = {
        path = lib.mkOption {
          type = lib.types.path;
          default = null;
        };
        desktopFileId = lib.mkOption {
          type = lib.types.singleLineStr;
        };
      };
      config = {
        xdg.terminal-exec = {
          enable = true;
          settings.default = [ hmArgs.config.terminal.desktopFileId ];
        };
      };
    };
}
