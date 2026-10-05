{
  # Prerequisites (one-time, not declarative because qBittorrent owns its conf):
  #   1. Connect to a Proton server that supports port forwarding (paid plans;
  #      e.g. the wg-1-tor config). Verify from inside the namespace with:
  #        sudo ip netns exec protonvpn natpmpc -a 1 0 udp 60 -g 10.2.0.1
  #   2. qBittorrent -> Options -> Web UI -> enable on 127.0.0.1:8080 and tick
  #      "Bypass authentication for clients on localhost".
  flake.modules.nixos.pc =
    { pkgs, lib, ... }:
    let
      gateway = "10.2.0.1"; # ProtonVPN NAT-PMP gateway
      webui = "http://127.0.0.1:8080";
      lifetime = 60; # lease seconds requested from the gateway
      interval = 45; # renew a little before the lease expires

      natpmp = pkgs.writeShellApplication {
        name = "qbittorrent-natpmp";
        runtimeInputs = with pkgs; [
          libnatpmp
          curl
          gnused
          coreutils
        ];
        text = ''
          last_port=""
          while true; do
            if ! udp=$(natpmpc -a 1 0 udp ${toString lifetime} -g ${gateway} 2>&1); then
              echo "[qbt-natpmp] gateway ${gateway} refused NAT-PMP (server has no port forwarding?); retrying"
              sleep ${toString interval}
              continue
            fi
            natpmpc -a 1 0 tcp ${toString lifetime} -g ${gateway} >/dev/null 2>&1 || true
            port=$(printf '%s\n' "$udp" | sed -n 's/.*Mapped public port \([0-9]\{1,\}\).*/\1/p' | head -n1)
            if [ -n "$port" ] && [ "$port" != "$last_port" ]; then
              if curl -sf "${webui}/api/v2/app/setPreferences" \
                  --data-urlencode "json={\"listen_port\":$port}" >/dev/null; then
                echo "[qbt-natpmp] forwarded port $port -> qBittorrent"
                last_port="$port"
              else
                echo "[qbt-natpmp] got port $port but Web API update failed (Web UI enabled on ${webui}?)"
              fi
            fi
            sleep ${toString interval}
          done
        '';
      };
    in
    {
      systemd.services.qbittorrent-natpmp = {
        description = "Renew ProtonVPN NAT-PMP port forward for qBittorrent";
        after = [ "netns-protonvpn.service" ];
        requires = [ "netns-protonvpn.service" ];
        bindsTo = [ "netns-protonvpn.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          # Join the split-tunnel namespace so 10.2.0.1 and the qBittorrent Web
          # UI on 127.0.0.1 are both reachable.
          NetworkNamespacePath = "/run/netns/protonvpn";
          ExecStart = lib.mkDefault (lib.getExe natpmp);
          Restart = lib.mkDefault "on-failure";
          RestartSec = lib.mkDefault 15;
        };
      };
    };
}
