{ inputs, ... }:
{
  flake.modules.homeManager.lazyvim = {
    imports = [ inputs.lazyvim.homeManagerModules.default ];

    programs.lazyvim = {
      enable = true;
    };

    stylix.targets.vim.enable = false;
    stylix.targets.neovim.enable = false;

    home.sessionVariables.EDITOR = "nvim";
    home.shellAliases.vim = "nvim";
  };
}
