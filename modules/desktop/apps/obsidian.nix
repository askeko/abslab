{
  flake.modules.homeManager.gui = {
    programs.obsidian = {
      enable = true;
      vaults.absentia-vault.target = "docs/absentia-vault";
    };
  };

  nixpkgs.config.allowUnfreePackages = [
    "obsidian"
  ];
}
