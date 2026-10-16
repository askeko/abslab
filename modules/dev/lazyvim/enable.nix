{ inputs, ... }:
{
  flake.modules.homeManager.lazyvim = {
    imports = [ inputs.lazyvim.homeManagerModules.default ];

    programs.lazyvim = {
      enable = true;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    home.shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
    };
  };
}
