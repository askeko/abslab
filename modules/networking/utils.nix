{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bandwhich
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
}
