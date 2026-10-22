{ lib, ... }:
{
  # Noctalia colours: its community LazyVim colourscheme, vendored in noctalia/
  # (noctalia-dev/community-templates@562507c, lazyvim/) without its apply.sh
  # hook. That hook writes this plugin spec and signals Neovim; both happen
  # here instead. LazyVim falls back to tokyonight where Noctalia hasn't
  # rendered the colourscheme (hosts without it, or before its first render).
  flake.modules.homeManager.lazyvim.programs.lazyvim.plugins.colorscheme = ''
    return {
      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = function()
            if not pcall(vim.cmd.colorscheme, "noctalia") then
              vim.cmd.colorscheme("tokyonight")
            end
          end,
        },
      },
    }
  '';

  # noctalia.lua is upstream's file with an abslab block appended (the end of
  # the file): Noctalia's built-in themes don't define Material's container
  # colours, so those, diffs and syntax are remapped to the theme's real and
  # terminal colours. lualine.lua is our own theme for lualine's auto loader.
  # Open Neovims reload both on SIGUSR1 (handler in the colourscheme); each
  # template signals, as either may render last.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      reload = "${lib.getExe' pkgs.procps "pkill"} -USR1 -x nvim || true";
    in
    {
      programs.noctalia.settings.theme.templates.user = {
        lazyvim = {
          input_path = lib.mkDefault "${./noctalia/noctalia.lua}";
          output_path = lib.mkDefault "$XDG_CONFIG_HOME/nvim/colors/noctalia.lua";
          post_hook = lib.mkDefault reload;
        };
        lazyvim_lualine = {
          input_path = lib.mkDefault "${./noctalia/lualine.lua}";
          output_path = lib.mkDefault "$XDG_CONFIG_HOME/nvim/lua/lualine/themes/noctalia.lua";
          post_hook = lib.mkDefault reload;
        };
      };
    };
}
