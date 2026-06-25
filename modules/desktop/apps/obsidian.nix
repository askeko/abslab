{
  flake.modules.homeManager.gui = {
    programs.obsidian = {
      enable = true;
      vaults.absentia-vault.target = "docs/absentia-vault";
    };

    stylix.targets.obsidian.vaultNames = [ "absentia-vault" ];
  };

  nixpkgs.config.allowUnfreePackages = [
    "obsidian"
  ];
}
