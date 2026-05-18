{
  flake.modules.homeManager.base = {
    programs.claude-code.enable = true;
  };
  nixpkgs.config.allowUnfreePackages = [
    "claude-code"
  ];
}
