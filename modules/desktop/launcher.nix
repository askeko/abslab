{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs@{ ... }:
    let
      mkLiteral = hmArgs.config.lib.formats.rasi.mkLiteral;
    in
    {
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
          display-drun = "󰍉  Apps";
          display-run = "  Run";
          display-window = "󰕰  Window";
        };
        theme = {
          window = {
            border = 2;
            border-radius = 12;
            border-color = mkLiteral "@blue";
            padding = 0;
            width = mkLiteral "40em";
          };
          mainbox = {
            border = 0;
            padding = 0;
          };
          message = {
            border = mkLiteral "0px";
            padding = mkLiteral "4px 12px";
          };
          inputbar = {
            spacing = mkLiteral "8px";
            padding = mkLiteral "14px 16px";
            border = mkLiteral "0px 0px 1px 0px";
            border-color = mkLiteral "@blue";
            children = mkLiteral "[ prompt, entry ]";
          };
          prompt.spacing = 0;
          entry.spacing = 0;
          listview = {
            fixed-height = false;
            border = mkLiteral "0px";
            spacing = mkLiteral "2px";
            scrollbar = false;
            padding = mkLiteral "8px";
            lines = 8;
          };
          element = {
            border = 0;
            border-radius = 8;
            padding = mkLiteral "8px 10px";
          };
          "element-icon".size = mkLiteral "24px";
          scrollbar = {
            width = mkLiteral "2px";
            border = 0;
            handle-width = mkLiteral "8px";
            padding = 0;
          };
        };
      };

      wayland.windowManager.hyprland.settings.bind =
        let
          rofi = lib.getExe hmArgs.config.programs.rofi.package;
        in
        [
          "SUPER, d, exec, ${rofi} -show drun"
          "SUPER+SHIFT, d, exec, ${rofi} -show run"
        ];
    };
}
