{ config, lib, ... }:
let
  wallpaperDir = config.flake.meta.theme.wallpaper.path;
  defaultWallpaper = "${wallpaperDir}/slick/apple-dark.jpg";
  # Stable symlink to the active wallpaper, re-pointed on every change. hyprlock
  # (screenlock.nix) reads this fixed path so the lock screen tracks the live wallpaper.
  currentLink = "$HOME/.local/state/theme/current-wallpaper";
in
{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      rofi = lib.getExe hmArgs.config.programs.rofi.package;
      # awww is the maintained swww fork; unit and CLI are both named awww.
      awww = lib.getExe hmArgs.config.services.awww.package;

      homeDir = hmArgs.config.home.homeDirectory;
      currentLinkAbs = "${homeDir}/.local/state/theme/current-wallpaper";

      applyWallpaper = ''
        apply_wallpaper() {
          local path="$1"
          mkdir -p "$HOME/.local/state/theme"
          ln -sf "$path" "${currentLink}"
          ${awww} img "$path" --transition-type fade
        }
      '';

      wallpaperPicker = pkgs.writeShellApplication {
        name = "wallpaper-picker";
        runtimeInputs = with pkgs; [
          findutils
          coreutils
          libnotify
        ];
        text = ''
          ${applyWallpaper}
          mkdir -p "$HOME/.local/state/theme"
          if selected_rel=$(
            find "${wallpaperDir}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) \
              | sort \
              | while IFS= read -r path; do
                  relpath="''${path#${wallpaperDir}/}"
                  printf '%s\0icon\x1f%s\n' "$relpath" "$path"
                done \
              | ${rofi} -dmenu -p "󰋩  Wallpaper" -show-icons -i \
                  -theme-str 'listview { columns: 4; } element-icon { size: 100px; }'
          ); then
            selected="${wallpaperDir}/$selected_rel"
            apply_wallpaper "$selected"
            notify-send -a "Wallpaper" -i "$selected" "Wallpaper changed" "$selected_rel"
          fi
        '';
      };

      # The symlink (not awww's own cache) is the source of truth: a retarget
      # made while logged out — e.g. by the theme specialisation — must win.
      wallpaper-restore = pkgs.writeShellApplication {
        name = "wallpaper-restore";
        runtimeInputs = [
          hmArgs.config.services.awww.package
          pkgs.coreutils
        ];
        text = ''
          for _ in $(seq 50); do
            if awww query >/dev/null 2>&1; then
              awww img "${currentLinkAbs}" --transition-type none
              exit 0
            fi
            sleep 0.2
          done
          echo "awww daemon never came up" >&2
          exit 1
        '';
      };
    in
    {
      programs.niri.settings.binds."Mod+B".action.spawn = "wallpaper-picker";

      home.packages = [ wallpaperPicker ];

      # wallpaperPicker notification
      services.mako.settings."app-name=Wallpaper" = {
        default-timeout = 2000;
        max-icon-size = 128;
      };

      # Ensure the symlink exists (pointing at the default) before the daemon
      # starts, so restore always resolves to a real file, even on a fresh
      # machine with no saved wallpaper state yet.
      home.activation.seedWallpaperLink = hmArgs.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "${homeDir}/.local/state/theme"
        if [ ! -e "${currentLinkAbs}" ]; then
          run ln -sf "${defaultWallpaper}" "${currentLinkAbs}"
        fi
      '';

      # awww: switches at runtime with a fade, which is what the picker relies on.
      services.awww.enable = true;

      systemd.user.services.wallpaper-restore = {
        Unit = {
          Description = "Restore wallpaper from the current-wallpaper symlink";
          After = [ "awww.service" ];
          BindsTo = [ "awww.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe wallpaper-restore;
          RemainAfterExit = true;
        };
        Install.WantedBy = [ "awww.service" ];
      };
    };
}
