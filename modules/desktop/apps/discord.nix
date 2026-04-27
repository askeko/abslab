{
  flake.modules.homeManager.gui = {
    programs.discord.enable = true;
  };

  nixpkgs.config.allowUnfreePackages = [
    "discord"
  ];
}
