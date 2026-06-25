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
      hyprctl = "${pkgs.hyprland}/bin/hyprctl";
      jq = "${pkgs.jq}/bin/jq";

      homeDir = hmArgs.config.home.homeDirectory;
      currentLinkAbs = "${homeDir}/.local/state/theme/current-wallpaper";

      applyWallpaper = ''
        apply_wallpaper() {
          local path="$1"
          mkdir -p "$HOME/.local/state/theme"
          ln -sf "$path" "${currentLink}"
          ${hyprctl} hyprpaper preload "$path" || true
          while IFS= read -r monitor; do
            ${hyprctl} hyprpaper wallpaper "$monitor,$path"
          done < <(${hyprctl} monitors -j | ${jq} -r '.[].name')
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

    in
    {
      wayland.windowManager.hyprland.settings = {
        misc.disable_hyprland_logo = true;
        bind = [ "SUPER, b, exec, wallpaper-picker" ];
      };

      home.packages = [ wallpaperPicker ];

      # wallpaperPicker notification
      services.mako.settings."app-name=Wallpaper" = {
        default-timeout = 2000;
        max-icon-size = 128;
      };

      # Ensure the symlink exists (pointing at the default) before hyprpaper
      # starts, so the build-time config below always resolves to a real file,
      # even on a fresh machine with no saved wallpaper state yet.
      home.activation.seedWallpaperLink = hmArgs.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "${homeDir}/.local/state/theme"
        if [ ! -e "${currentLinkAbs}" ]; then
          run ln -sf "${defaultWallpaper}" "${currentLinkAbs}"
        fi
      '';

      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          preload = [ currentLinkAbs ];
          wallpaper = [
            {
              monitor = "";
              path = currentLinkAbs;
              fit_mode = "stretch";
            }
          ];
        };
      };
    };
}
