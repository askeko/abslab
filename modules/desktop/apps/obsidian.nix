{
  # Rosé Pine's Obsidian port is a community theme, installed and selected in
  # Obsidian (Settings -> Appearance -> Themes), which keeps it in the vault.
  flake.modules.homeManager.gui.programs.obsidian = {
    enable = true;
    vaults.absentia-vault.target = "docs/absentia-vault";
  };

  nixpkgs.config.allowUnfreePackages = [
    "obsidian"
  ];
}
