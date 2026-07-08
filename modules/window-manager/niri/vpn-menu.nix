{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, lib, ... }:
    let
      vpn-menu = pkgs.writeShellApplication {
            name = "vpn-menu";
            runtimeInputs = [
              hmArgs.config.programs.rofi.package
              pkgs.wireguard-tools
              pkgs.iproute2
              pkgs.jq
              pkgs.libnotify
            ];
            text = ''
              active=$(ip -j -d link show | jq -r '[.[] | select(.linkinfo.info_kind == "wireguard")] | .[0].ifname // empty')
              configs=$(find /etc/wireguard -maxdepth 1 -name '*.conf' -printf '%f\n' | sed 's/\.conf$//' | sort)

              if [ -n "$active" ]; then
                menu=$(printf "󰦞  Disconnect (%s)\n%s" "$active" "$configs")
              else
                menu="$configs"
              fi

              choice=$(printf "%s\n" "$menu" | rofi -dmenu -p 'VPN: ')

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
      programs.niri.settings.binds."Mod+Shift+V".action.spawn = lib.getExe vpn-menu;
    };
}
