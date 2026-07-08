# SUPER+SHIFT+S toggles between the light and dark themes
{ config, ... }:
let
  theme = config.flake.meta.theme;
  baseMode = theme.mode;
  otherMode = if theme.mode == "dark" then "light" else "dark";
  stateRel = ".local/state/theme/polarity";

  systemProfile = "/nix/var/nix/profiles/system";

  mkSwitchPriv =
    pkgs:
    pkgs.writeShellScript "theme-switch-priv" ''
      set -euo pipefail
      case "''${1:-}" in
        ${baseMode})
          exec ${systemProfile}/bin/switch-to-configuration switch
          ;;
        ${otherMode})
          exec ${systemProfile}/specialisation/${otherMode}/bin/switch-to-configuration switch
          ;;
        *)
          echo "usage: theme-switch-priv ${baseMode}|${otherMode}" >&2
          exit 1
          ;;
      esac
    '';
in
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      security.sudo-rs.extraRules = [
        {
          users = [ config.flake.meta.owner.username ];
          commands = [
            {
              command = "${mkSwitchPriv pkgs}";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };

  flake.modules.homeManager.gui =
    {
      pkgs,
      lib,
      osConfig ? null,
      ...
    }:
    let
      mode = if osConfig != null && osConfig ? stylix then osConfig.stylix.polarity else baseMode;

      theme-toggle = pkgs.writeShellApplication {
        name = "theme-toggle";
        runtimeInputs = [ pkgs.libnotify ];
        text = ''
          fail() {
            notify-send -a theme -u critical "Theme switch failed" "$1"
            exit 1
          }

          marker="$HOME/${stateRel}"
          current=$(cat "$marker" 2>/dev/null || echo "${baseMode}")
          if [ "$current" = "${baseMode}" ]; then
            target="${otherMode}"
          else
            target="${baseMode}"
          fi

          if [ "$target" = "${otherMode}" ] \
             && [ ! -x "${systemProfile}/specialisation/${otherMode}/bin/switch-to-configuration" ]; then
            fail "No '${otherMode}' specialisation in the system profile — run: sudo nixos-rebuild switch"
          fi

          if /run/wrappers/bin/sudo ${mkSwitchPriv pkgs} "$target"; then
            notify-send -a theme "Theme" "Switched to $target mode"
          else
            fail "switch-to-configuration for '$target' failed — check: journalctl -e"
          fi
        '';
      };
    in
    {
      home.file.${stateRel}.text = mode;

      programs.niri.settings.binds."Mod+Shift+S".action.spawn = lib.getExe theme-toggle;
    };
}
