{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        spotify
      ];
    };

  nixpkgs.config.allowUnfreePackages = [
    "spotify"
  ];
}
