{ config, lib, ... }:
let
  palette = config.flake.meta.rosePine;
in
{
  # Rosé Pine has no zathura port: its palette on zathura's own colours.
  flake.modules.homeManager.gui = {
    programs.zathura = {
      enable = true;
      options = lib.mapAttrs (_: lib.mkDefault) (
        with palette;
        {
          default-bg = base;
          default-fg = text;
          statusbar-bg = surface;
          statusbar-fg = text;
          inputbar-bg = surface;
          inputbar-fg = text;
          notification-bg = surface;
          notification-fg = text;
          completion-bg = surface;
          completion-fg = text;
          completion-highlight-bg = highlightMed;
          completion-highlight-fg = text;
          highlight-color = gold;
          highlight-active-color = iris;
          recolor-lightcolor = base;
          recolor-darkcolor = text;
        }
      );
    };
    xdg.mimeApps.defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
  };
}
