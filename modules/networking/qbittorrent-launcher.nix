{ config, ... }:
{
  # Launch the qBittorrent GUI inside the protonvpn network namespace (see
  # networking/netns-protonvpn.nix)
  flake.modules.nixos.pc =
    { pkgs, lib, ... }:
    let
      username = config.flake.meta.owner.username;
      realQbt = lib.getExe pkgs.qbittorrent;

      # Runs as root via sudo. Args: VAR=val ... -- [qbittorrent args]
      rootHelper = pkgs.writeShellApplication {
        name = "qbittorrent-netns";
        runtimeInputs = with pkgs; [
          iproute2
          util-linux
          coreutils
        ];
        text = ''
          envs=()
          while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do
            envs+=("$1")
            shift
          done
          [ "''${1:-}" = "--" ] && shift

          exec ip netns exec protonvpn \
            setpriv --reuid "$SUDO_UID" --regid "$SUDO_GID" --init-groups \
            env HOME=${lib.escapeShellArg "/home/${username}"} USER=${lib.escapeShellArg username} \
                LOGNAME=${lib.escapeShellArg username} "''${envs[@]}" \
            ${realQbt} "$@"
        '';
      };

      # User-facing wrapper: forwards the session env the GUI needs, then hands
      # off to the pinned root helper via passwordless sudo.
      launcher = pkgs.writeShellApplication {
        name = "qbittorrent";
        runtimeInputs = [ ]; # sudo lives at the wrapper path below
        text = ''
          exec /run/wrappers/bin/sudo ${lib.getExe rootHelper} \
            "WAYLAND_DISPLAY=''${WAYLAND_DISPLAY:-}" \
            "XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-}" \
            "DBUS_SESSION_BUS_ADDRESS=''${DBUS_SESSION_BUS_ADDRESS:-}" \
            "DISPLAY=''${DISPLAY:-}" \
            "XAUTHORITY=''${XAUTHORITY:-}" \
            "XDG_CURRENT_DESKTOP=''${XDG_CURRENT_DESKTOP:-}" \
            "XDG_SESSION_TYPE=''${XDG_SESSION_TYPE:-}" \
            "XDG_DATA_DIRS=''${XDG_DATA_DIRS:-}" \
            "QT_QPA_PLATFORM=''${QT_QPA_PLATFORM:-}" \
            "QT_QPA_PLATFORMTHEME=''${QT_QPA_PLATFORMTHEME:-}" \
            "LANG=''${LANG:-}" \
            -- "$@"
        '';
      };

      # Keep qBittorrent's real binary, .desktop (Exec=qbittorrent, PATH-resolved)
      # and icons; just swap bin/qbittorrent for the namespace launcher so both
      # the app-launcher entry and the CLI go through the tunnel.
      qbittorrentVpn = pkgs.symlinkJoin {
        name = "qbittorrent-vpn-${pkgs.qbittorrent.version}";
        paths = [ pkgs.qbittorrent ];
        postBuild = ''
          rm -f "$out/bin/qbittorrent"
          ln -s ${lib.getExe launcher} "$out/bin/qbittorrent"
        '';
      };
    in
    {
      environment.systemPackages = [ qbittorrentVpn ];

      security.sudo-rs.extraRules = [
        {
          users = [ username ];
          commands = [
            {
              command = lib.getExe rootHelper;
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
}
