{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      satty = lib.getExe hmArgs.config.programs.satty.package;

      screenshot-area-edit = pkgs.writeShellApplication {
        name = "screenshot-area-edit";
        runtimeInputs = [
          pkgs.grim
          pkgs.slurp
        ];
        text = ''
          grim -g "$(slurp)" - | ${satty} --filename -
        '';
      };

      screenshot-output-edit = pkgs.writeShellApplication {
        name = "screenshot-output-edit";
        runtimeInputs = [
          pkgs.grim
          pkgs.jq
          hmArgs.config.programs.niri.package
        ];
        text = ''
          grim -o "$(niri msg --json focused-output | jq -r .name)" - | ${satty} --filename -
        '';
      };

      # grim can't capture a single window on niri; the compositor action
      # saves the focused window to disk + clipboard, and satty edits the
      # clipboard copy (cleared first so a stale image can't sneak in).
      screenshot-window-edit = pkgs.writeShellApplication {
        name = "screenshot-window-edit";
        runtimeInputs = [
          pkgs.wl-clipboard-rs
          hmArgs.config.programs.niri.package
          pkgs.coreutils
        ];
        text = ''
          tmp=$(mktemp --suffix .png)
          trap 'rm -f "$tmp"' EXIT
          wl-copy --clear
          niri msg action screenshot-window
          for _ in $(seq 20); do
            if wl-paste --type image/png > "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
              ${satty} --filename "$tmp"
              exit 0
            fi
            sleep 0.1
          done
          echo "screenshot never arrived on the clipboard" >&2
          exit 1
        '';
      };
    in
    {
      home.packages = [
        hmArgs.config.programs.satty.package
      ];

      programs.satty = {
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

      programs.niri.settings = {
        # Same directory + naming as satty's output-filename.
        screenshot-path = "${hmArgs.config.xdg.userDirs.desktop}/screenshot-%Y-%m-%d_%H:%M:%S.png";
        binds = {
          "Mod+Shift+W".action.spawn = lib.getExe screenshot-window-edit;
          "Mod+Shift+O".action.spawn = lib.getExe screenshot-output-edit;
          "Mod+Shift+R".action.spawn = lib.getExe screenshot-area-edit;
          # niri's built-in interactive screenshot UI (area/window/screen)
          "Print".action.screenshot = [ ];
        };
      };
    };
}
