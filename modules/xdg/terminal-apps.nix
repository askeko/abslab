{ lib, ... }:
{
  # nvim.desktop and yazi.desktop are Terminal=true, which xdg-open (xdg-utils
  # 1.2.1) ignores, so text files and folders open through these entries that
  # start them in the terminal explicitly.
  flake.modules.homeManager.gui =
    hmArgs:
    let
      term = hmArgs.config.terminal.path;

      textTypes = [
        "text/plain"
        "text/markdown"
        "text/x-python"
        "text/x-lua"
        "text/x-log"
        "text/x-readme"
        "text/x-csrc"
        "text/x-chdr"
        "text/x-c++src"
        "text/x-c++hdr"
        "text/rust"
        "text/x-go"
        "text/x-haskell"
        "text/x-tex"
        "text/x-makefile"
        "text/x-cmake"
        "text/javascript"
        "application/x-shellscript"
        "application/json"
        "application/toml"
        "application/yaml"
      ];
    in
    {
      xdg.desktopEntries = {
        nvim-terminal = {
          name = "Neovim (terminal)";
          exec = "${term} -e nvim %F";
          icon = "nvim";
          noDisplay = true;
          mimeType = [ "text/plain" ];
        };
        yazi-terminal = {
          name = "Yazi (terminal)";
          exec = "${term} -e yazi %f";
          icon = "yazi";
          noDisplay = true;
          mimeType = [ "inode/directory" ];
        };
      };

      xdg.mimeApps.defaultApplications = lib.genAttrs textTypes (_: [ "nvim-terminal.desktop" ]) // {
        "inode/directory" = [ "yazi-terminal.desktop" ];
      };
    };
}
