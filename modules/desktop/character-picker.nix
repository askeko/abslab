{ lib, ... }:
{
  # Emoji and every other Unicode character (rofimoji's lists), recently used
  # first, picked in Noctalia's launcher and typed into the focused window.
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      # rofimoji's dmenu selector, shown in Noctalia's launcher (which only
      # takes -p).
      dmenu = pkgs.writeShellApplication {
        name = "dmenu";
        runtimeInputs = [ hmArgs.config.programs.noctalia.package ];
        text = ''
          prompt=Characters
          while [ $# -gt 0 ]; do
            case "$1" in
            -p) prompt=$2 && shift 2 ;;
            *) shift ;;
            esac
          done
          exec noctalia dmenu -p "$prompt"
        '';
      };

      character-picker = pkgs.writeShellApplication {
        name = "character-picker";
        runtimeInputs = with pkgs; [
          rofimoji
          dmenu
          wtype
        ];
        text = ''
          exec rofimoji --selector dmenu --typer wtype --action type --files all
        '';
      };
    in
    {
      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + U", app("${lib.getExe character-picker}"), "Character picker")
      '';
    };
}
