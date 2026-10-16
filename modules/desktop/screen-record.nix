{ lib, ... }:
{
  # Records a selected area to the desktop dir (~/tmp); run again to stop.
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      screen-record = pkgs.writeShellApplication {
        name = "screen-record";
        runtimeInputs = with pkgs; [
          wf-recorder
          slurp
          libnotify
          procps
          coreutils
        ];
        text = ''
          if pkill -INT -x wf-recorder; then
              exit 0
          fi

          geometry=$(slurp) || exit 0
          file="${hmArgs.config.xdg.userDirs.desktop}/recording-$(date +%Y-%m-%d_%H:%M:%S).mp4"

          notify-send -a Recorder "Recording started" "Mod+Shift+C stops it"
          wf-recorder -g "$geometry" -f "$file" || true
          if [ -s "$file" ]; then
              notify-send -a Recorder "Recording saved" "$file"
          else
              notify-send -a Recorder -u critical "Recording failed"
          fi
        '';
      };
    in
    {
      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + SHIFT + C", app("${lib.getExe screen-record}"), "Start/stop screen recording")
      '';
    };
}
