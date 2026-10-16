{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      # Region, monitor and annotate shots are Noctalia's; the focused window
      # is cut out of a grim capture and opened in satty.
      screenshot-window = pkgs.writeShellApplication {
        name = "screenshot-window";
        runtimeInputs = [
          pkgs.hyprland
          pkgs.jq
          pkgs.grim
          hmArgs.config.programs.satty.package
        ];
        text = ''
          geometry=$(hyprctl -j activewindow | jq -r 'if .at then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else empty end')
          [ -n "$geometry" ] || exit 1
          grim -g "$geometry" - | satty --filename -
        '';
      };
    in
    {
      programs = {
        satty = {
          enable = true;
          settings.general = {
            corner-roundness = 6;
            initial-tool = "brush";
            copy-command = lib.getExe' pkgs.wl-clipboard-rs "wl-copy";
            output-filename = "${hmArgs.config.xdg.userDirs.desktop}/screenshot-%Y-%m-%d_%H:%M:%S.png";
            actions-on-enter = [ "save-to-clipboard" ];
            actions-on-escape = [ "exit" ];
          };
        };

        noctalia.settings.shell.screenshot = {
          save_to_file = lib.mkDefault false;
          copy_to_clipboard = lib.mkDefault true;
        };
      };

      wayland.windowManager.hyprland.extraConfig = ''
        bind("Print", cmd(ipc .. "screenshot-region"), "Screenshot area to clipboard")
        bind(mod .. " + SHIFT + R", cmd(ipc .. "screenshot-annotate"), "Screenshot area, edit")
        bind(mod .. " + SHIFT + O", cmd(ipc .. "screenshot-fullscreen"), "Screenshot monitor")
        bind(mod .. " + SHIFT + W", app("${lib.getExe screenshot-window}"), "Screenshot window, edit")
      '';
    };
}
