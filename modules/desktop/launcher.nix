{ lib, ... }:
{
  flake.modules.homeManager.gui = hmArgs: {
    programs.rofi = {
      enable = true;
      terminal = hmArgs.config.terminal.path;
      modes = [
        "run"
        "drun"
        "window"
      ];
      extraConfig = {
        show-icons = true;
        drun-display-format = "{icon} {name}";
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-window = " 󰕰  Window";
        display-Network = " 󰤨  Network";
      };
      theme = {
        listview.columns = 1;
        "*".width = 1200;
      };
    };
  };
}
