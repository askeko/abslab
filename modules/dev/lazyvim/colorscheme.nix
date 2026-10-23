{ lib, ... }:
{
  # Noctalia supplies the palette; Tokyo Night supplies syntax/plugin highlights.
  # Re-read the rendered file on SIGUSR1, including changes within the same mode.
  # Without Noctalia, fall back to Tokyo Night's dark palette.
  flake.modules.homeManager.lazyvim.programs.lazyvim.plugins.colorscheme = ''
    local theme

    local function apply()
      local ok, value = pcall(dofile, vim.fn.stdpath("config") .. "/noctalia-theme.lua")
      theme = ok and type(value) == "table" and value or nil
      vim.o.background = theme and theme.mode == "light" and "light" or "dark"
      vim.cmd.colorscheme("tokyonight")
    end

    return {
      {
        "folke/tokyonight.nvim",
        opts = {
          style = "night",
          light_style = "day",
          on_colors = function(colors)
            if theme and theme.on_colors then
              theme.on_colors(colors)
            end
          end,
        },
      },
      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = function()
            apply()
            vim.api.nvim_create_autocmd("Signal", {
              group = vim.api.nvim_create_augroup("NoctaliaTheme", { clear = true }),
              pattern = "SIGUSR1",
              callback = apply,
              nested = true, -- Let ColorScheme handlers refresh plugin highlights.
              desc = "Reload Noctalia's palette",
            })
          end,
        },
      },
    }
  '';

  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      programs.noctalia.settings.theme.templates.user.lazyvim_theme = {
        input_path = lib.mkDefault "${./noctalia/theme.lua}";
        output_path = lib.mkDefault "$XDG_CONFIG_HOME/nvim/noctalia-theme.lua";
        post_hook = lib.mkDefault "${lib.getExe' pkgs.procps "pkill"} -USR1 -x nvim || true";
      };
    };
}
