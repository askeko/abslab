{
  # ProtonVPN forwards no inbound ports on a plain WireGuard tunnel, so
  # qBittorrent shows as "unconnectable" on trackers. Proton's only inbound
  # mechanism is NAT-PMP against the tunnel gateway (10.2.0.1), which hands out
  # a *random* port on a 60s lease that must be renewed. This user service
  # renews the lease and pushes the assigned port into qBittorrent's live
  # config via its Web API.
  #
  # Prerequisites (one-time, not declarative because qBittorrent owns its conf):
  #   1. Connect to a Proton server that supports port forwarding (paid plans;
  #      e.g. the wg-1-tor config). Verify with:
  #        natpmpc -a 1 0 udp 60 -g 10.2.0.1
  #   2. qBittorrent -> Options -> Advanced -> Network Interface = the wg-* iface
  #      (stops IP leaks over wlan0).
  #   3. qBittorrent -> Options -> Web UI -> enable on 127.0.0.1:8080 and tick
  #      "Bypass authentication for clients on localhost".
  # The forwarded port is random per session, so we can't open a fixed port in
  # the firewall; trust the ProtonVPN tunnel interface instead. Inbound is only
  # reachable from the VPN side (physical NICs stay firewalled) and nothing
  # sensitive binds to 0.0.0.0 (qBittorrent's Web UI is loopback-only), so the
  # exposure is limited to other Proton peers on the internal subnet.
  # Plain list (not mkDefault): trustedInterfaces merges by concatenation, and a
  # mkDefault definition would be discarded whenever another module sets the
  # option at normal priority (e.g. the implicit "lo"), so this must merge.
  flake.modules.nixos.pc = {
    networking.firewall.trustedInterfaces = [ "wg-1-tor" ];
  };

  flake.modules.homeManager.gui =
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
      systemd.user.services.qbittorrent-natpmp = {
        Unit = {
          Description = "Renew ProtonVPN NAT-PMP port forward for qBittorrent";
          After = [ "network-online.target" ];
        };
        Service = {
          ExecStart = lib.mkDefault (lib.getExe natpmp);
          Restart = lib.mkDefault "on-failure";
          RestartSec = lib.mkDefault 15;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
