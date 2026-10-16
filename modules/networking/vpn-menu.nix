{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, lib, ... }:
    let
      vpn-menu = pkgs.writeShellApplication {
        name = "vpn-menu";
        runtimeInputs = [
          hmArgs.config.programs.noctalia.package
          pkgs.wireguard-tools
          pkgs.iproute2
          pkgs.jq
          pkgs.libnotify
        ];
        text = ''
          active=$(ip -j -d link show | jq -r '[.[] | select(.linkinfo.info_kind == "wireguard")] | .[0].ifname // empty')
          # wg-1-tor is owned by the always-on protonvpn split-tunnel
          # namespace (networking/netns-protonvpn.nix), not a full-tunnel
          # toggle — exclude it to avoid an interface-name collision.
          configs=$(find /etc/wireguard -maxdepth 1 -name '*.conf' -printf '%f\n' | sed 's/\.conf$//' | grep -vx 'wg-1-tor' | sort)

          if [ -n "$active" ]; then
            menu=$(printf "󰦞  Disconnect (%s)\n%s" "$active" "$configs")
          else
            menu="$configs"
          fi

          choice=$(printf "%s\n" "$menu" | noctalia dmenu -p VPN)

          notify() {
            notify-send -a VPN -i network-vpn "$1" "''${2:-}"
          }

          trap 'notify-send -a VPN -u critical "VPN error" "Command failed - check journalctl"' ERR

          case "$choice" in
            "")
              exit 1
              ;;
            *Disconnect*)
              /run/wrappers/bin/sudo wg-quick down "$active"
              notify "VPN disconnected" "$active"
              ;;
            *)
              if [ -n "$active" ]; then
                /run/wrappers/bin/sudo wg-quick down "$active"
              fi
              /run/wrappers/bin/sudo wg-quick up "$choice"
              notify "VPN connected" "$choice"
              ;;
          esac
        '';
      };
    in
    {
      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + SHIFT + V", app("${lib.getExe vpn-menu}"), "VPN menu")
      '';

      programs.noctalia.settings.widget.vpn = {
        type = lib.mkDefault "custom_button";
        glyph = lib.mkDefault "shield-lock";
        tooltip = lib.mkDefault "VPN menu";
        actions.left = lib.mkDefault "exec ${lib.getExe vpn-menu}";
      };
    };
}
