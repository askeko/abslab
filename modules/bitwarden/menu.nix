{ lib, ... }:
{
  # Mod+M: pick a Bitwarden entry, then what to type, in Noctalia's launcher.
  # Secrets go from the rbw agent straight to wtype (stdin, not argv) and are
  # typed into the focused window; nothing touches the clipboard.
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      rbw-menu = pkgs.writeShellApplication {
        name = "rbw-menu";
        runtimeInputs = with pkgs; [
          hmArgs.config.programs.rbw.package
          hmArgs.config.programs.noctalia.package
          hyprland
          jq
          libnotify
          wtype
          coreutils
        ];
        text = ''
          # The window to type into: the one focused before any menu or unlock prompt.
          focused() { hyprctl -j activewindow | jq -r '.address // empty'; }
          target=$(focused)

          choice=$(rbw list --fields name,user,folder | noctalia dmenu -p Passwords) || exit 0

          # name<TAB>user<TAB>folder; user and folder may be empty.
          name=''${choice%%$'\t'*}
          user="" folder=""
          if [ "$choice" != "$name" ]; then
            rest=''${choice#*$'\t'}
            user=''${rest%%$'\t'*}
            folder=''${rest#*$'\t'}
          fi
          args=("$name")
          [ -n "$user" ] && args+=("$user")
          [ -n "$folder" ] && args+=(--folder "$folder")

          actions=()
          [ -n "$user" ] && actions+=("Login (username ⇥ password)")
          actions+=("Password")
          [ -n "$user" ] && actions+=("Username")
          rbw code "''${args[@]}" >/dev/null 2>&1 && actions+=("TOTP")
          action=$(printf '%s\n' "''${actions[@]}" | noctalia dmenu -p "$name") || exit 0

          # Fetch everything before typing, so a failure never leaves a half-filled form.
          secret=""
          case "$action" in
          Login* | Password) secret=$(rbw get "''${args[@]}") ;;
          TOTP) secret=$(rbw code "''${args[@]}") ;;
          esac

          # Type only into the window that was focused before; never elsewhere.
          sleep 0.3 # let focus return to it after the launcher closes
          if [ -z "$target" ] || [ "$(focused)" != "$target" ]; then
            notify-send -a Passwords -u critical "Nothing typed" "Focus moved away from the original window"
            exit 1
          fi

          type_secret() { printf '%s' "$1" | wtype -; }
          case "$action" in
          Login*)
            type_secret "$user"
            wtype -k Tab
            type_secret "$secret"
            ;;
          Password | TOTP) type_secret "$secret" ;;
          Username) type_secret "$user" ;;
          esac
        '';
      };
    in
    {
      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + M", app("${lib.getExe rbw-menu}"), "Passwords")
      '';
    };
}
