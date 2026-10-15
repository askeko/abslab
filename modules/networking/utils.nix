{ lib, ... }:
{
  flake.modules = {
    # NixOS module rather than an HM package: it grants the capture
    # capabilities, so bandwhich runs without sudo.
    nixos.base.programs.bandwhich.enable = lib.mkDefault true;

    homeManager.base =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          bind # for dig
          curl
          ethtool
          gping
          inetutils
          socat
          wifite2
          # qbittorrent is provided system-wide (VPN-namespaced) by
          # networking/qbittorrent-launcher.nix
        ];
      };
  };
}
