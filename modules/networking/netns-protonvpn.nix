{
  # Always-on network namespace that carries ProtonVPN's `wg-1-tor` tunnel for
  # qBittorrent alone (split tunnel). The rest of the machine keeps using the
  # normal network; only processes launched inside this namespace (qBittorrent
  # + the qbittorrent-natpmp renewer) can reach the internet, and only via the
  # tunnel — so if the tunnel drops they lose connectivity instead of leaking.
  #
  # The WireGuard interface is *created in the init namespace* and then *moved*
  # into `protonvpn`: WireGuard fixes the encrypted UDP socket to the namespace
  # the device was created in, so the ciphertext still egresses over the
  # physical NIC / normal routing while cleartext apps live in the isolated ns.
  #
  # The tunnel config is the sops-decrypted /etc/wireguard/wg-1-tor.conf (see
  # networking/wireguard.nix). `wg setconf` rejects wg-quick-only keys
  # (Address/DNS/MTU/Table), so we feed it `wg-quick strip` output and apply the
  # Address/MTU/route ourselves inside the namespace.
  flake.modules.nixos.pc =
    { pkgs, lib, ... }:
    let
      ns = "protonvpn";
      iface = "wg-1-tor";
      conf = "/etc/wireguard/${iface}.conf";

      netns = pkgs.writeShellApplication {
        name = "netns-protonvpn";
        runtimeInputs = with pkgs; [
          iproute2
          wireguard-tools
          gnused
          coreutils
        ];
        text = ''
          ns=${ns}
          iface=${iface}
          conf=${conf}

          case "''${1:-up}" in
            up)
              ip netns list | grep -qw "$ns" || ip netns add "$ns"

              # Start from a clean slate: drop any stale interface in either ns.
              ip -n "$ns" link del "$iface" 2>/dev/null || true
              ip link del "$iface" 2>/dev/null || true

              # Create in the init ns (ciphertext egresses via the real NIC),
              # load keys/peers, then move the interface into the namespace.
              ip link add "$iface" type wireguard
              wg setconf "$iface" <(wg-quick strip "$iface")
              ip link set "$iface" netns "$ns"

              ip -n "$ns" link set lo up

              # Split multi-value "Address = v4/len, v6/len" on commas; strip
              # only spaces/tabs (NOT newlines, or the entries would rejoin).
              addrs=$(sed -n 's/^[[:space:]]*Address[[:space:]]*=[[:space:]]*//p' "$conf" | tr ',' '\n' | tr -d '[:blank:]')
              mtu=$(sed -n 's/^[[:space:]]*MTU[[:space:]]*=[[:space:]]*//p' "$conf" | tr -d '[:blank:]' | head -n1)

              has4=false
              has6=false
              for a in $addrs; do
                ip -n "$ns" address add "$a" dev "$iface"
                case "$a" in
                  *:*) has6=true ;;
                  *) has4=true ;;
                esac
              done

              [ -n "$mtu" ] && ip -n "$ns" link set "$iface" mtu "$mtu"
              ip -n "$ns" link set "$iface" up

              if $has4; then ip -n "$ns" route add default dev "$iface"; fi
              if $has6; then ip -n "$ns" -6 route add default dev "$iface"; fi
              ;;
            down)
              # Deleting the namespace also removes the interface it holds.
              ip netns del "$ns" 2>/dev/null || true
              ip link del "$iface" 2>/dev/null || true
              ;;
          esac
        '';
      };
    in
    {
      systemd.services.netns-protonvpn = {
        description = "ProtonVPN split-tunnel network namespace for qBittorrent";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${lib.getExe netns} up";
          ExecStop = "${lib.getExe netns} down";
        };
      };

      # `ip netns exec` bind-mounts /etc/netns/<ns>/resolv.conf over
      # /etc/resolv.conf inside the namespace so tracker DNS resolves via the
      # tunnel. 10.2.0.1 is Proton's in-tunnel resolver (also the NAT-PMP gw).
      environment.etc."netns/${ns}/resolv.conf".text = "nameserver 10.2.0.1\n";
    };
}
