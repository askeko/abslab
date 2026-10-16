{ lib, ... }:
{
  flake.modules.homeManager.gui = hmArgs: {
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
      home.sessionVariables.TERMINAL = hmArgs.config.terminal.path;

      xdg.terminal-exec = {
        enable = true;
        settings.default = [ hmArgs.config.terminal.desktopFileId ];
      };
      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + Return", app("${hmArgs.config.terminal.path}"), "Terminal")
      '';
    };
  };
}
