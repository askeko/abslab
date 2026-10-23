{
  # Rosé Pine's Neovim port, loaded from the store (`dir`), since lazy.nvim
  # would otherwise clone it.
  flake.modules.homeManager.lazyvim =
    { pkgs, ... }:
    {
      programs.lazyvim.plugins.colorscheme = ''
        return {
          { dir = "${pkgs.vimPlugins.rose-pine}", name = "rose-pine", lazy = true },
          { "LazyVim/LazyVim", opts = { colorscheme = "rose-pine-main" } },
        }
      '';
    };
}
