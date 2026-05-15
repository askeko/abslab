{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        obsidian
      ];
    };

  nixpkgs.config.allowUnfreePackages = [
    "obsidian"
  ];
}
