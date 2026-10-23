{ lib, ... }:
{
  # Colours follow Noctalia, live. Noctalia's built-in themes get their real
  # Neovim colourschemes, recognised by their exact background in the rendered
  # noctalia-theme.lua; other palettes (other built-ins, wallpaper themes) get
  # the generated noctalia colourscheme. Without Noctalia (hosts without it, or
  # before its first render) it's LazyVim's tokyonight. SIGUSR1 (the templates'
  # hooks) applies the current palette again.
  flake.modules.homeManager.lazyvim.programs.lazyvim.plugins.colorscheme = ''
    local schemes = {
      ["#1a1b26"] = "tokyonight-moon", -- Tokyo-Night
      ["#e1e2e7"] = "tokyonight-day",
    }

    local function apply()
      local ok, theme = pcall(dofile, vim.fn.stdpath("config") .. "/noctalia-theme.lua")
      local name = ok and schemes[theme.surface:lower()] or "noctalia"
      if not pcall(vim.cmd.colorscheme, name) then
        vim.cmd.colorscheme("tokyonight")
      end
    end

    return {
      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = function()
            apply()
            if not _G.__abslab_theme_signal then
              _G.__abslab_theme_signal = vim.uv.new_signal()
              _G.__abslab_theme_signal:start("sigusr1", vim.schedule_wrap(apply))
            end
          end,
        },
      },
    }
  '';

  # noctalia.lua is upstream's community LazyVim colourscheme
  # (noctalia-dev/community-templates@562507c, lazyvim/) with an abslab block
  # appended: Noctalia's built-in themes don't define Material's container
  # colours, so those, diffs and syntax are remapped to the theme's real and
  # terminal colours. lualine.lua is our own theme for lualine's auto loader.
  # Each template signals open Neovims, as any may render last.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      reload = "${lib.getExe' pkgs.procps "pkill"} -USR1 -x nvim || true";
    in
    {
      programs.noctalia.settings.theme.templates.user = {
        lazyvim_theme = {
          input_path = lib.mkDefault "${./noctalia/theme.lua}";
          output_path = lib.mkDefault "$XDG_CONFIG_HOME/nvim/noctalia-theme.lua";
          post_hook = lib.mkDefault reload;
        };
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
