{ config, ... }:
{
  flake.modules.nixos.pc =
    { pkgs, lib, ... }:
    let
      # Sops-encrypted WireGuard configs (e.g. ProtonVPN downloads). Drop a
      # `sops -e`-encrypted <name>.conf in secrets/wireguard/ and it is
      # decrypted to /etc/wireguard/<name>.conf at activation, where vpn-menu
      # picks it up. Keep names <= 15 chars: wg-quick uses the filename as the
      # interface name.
      confDir = ../../secrets/wireguard;
      confs = lib.optionals (builtins.pathExists confDir) (
        builtins.readDir confDir |> builtins.attrNames |> builtins.filter (lib.hasSuffix ".conf")
      );
    in
    {
      environment.systemPackages = [ pkgs.wireguard-tools ];

      # Filenames readable to regular users; .conf contents stay root-only
      systemd.tmpfiles.rules = [ "d /etc/wireguard 0755 root root -" ];

      sops.secrets =
        confs
        |> map (name: {
          name = "wireguard/${name}";
          value = {
            format = "binary";
            sopsFile = confDir + "/${name}";
            path = "/etc/wireguard/${name}";
          };
        })
        |> builtins.listToAttrs;

      security.sudo-rs.extraRules = [
        {
          users = [ config.flake.meta.owner.username ];
          commands = [
            {
              command = "${pkgs.wireguard-tools}/bin/wg-quick";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
}
