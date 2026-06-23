{ config, ... }:
{
  # TODO: Add configs to sops-nix later
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.wireguard-tools ];

      # Filenames readable to regular users; .conf contents stay 0600/root
      systemd.tmpfiles.rules = [ "d /etc/wireguard 0755 root root -" ];

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
