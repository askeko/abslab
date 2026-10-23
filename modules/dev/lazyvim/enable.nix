{ inputs, ... }:
{
  flake.modules.homeManager.lazyvim = hmArgs: {
    imports = [ inputs.lazyvim.homeManagerModules.default ];

    programs.lazyvim = {
      enable = true;

      config = {
        options = ''
          local opt = vim.opt

          opt.colorcolumn = "80" -- Visual bar at the preferred line length
          opt.scrolloff = 8 -- Always keep 8 lines visible when scrolling
          opt.shiftwidth = 4 -- Size of indents
          opt.tabstop = 4 -- Number of spaces a tab counts for
        '';

        keymaps = ''
          -- Visual line moves lines
          vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Lines Down" })
          vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Lines Up" })

          -- Cursor stays when joining lines
          vim.keymap.set("n", "J", "mzJ`z", { desc = "Join Lines" })
          -- Cursor in the middle when half page jumping
          vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half Page Down" })
          vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half Page Up" })
          -- Search terms stay in the middle
          vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
          vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev Search Result" })

          -- Neovim's built-in undotree (0.12+); toggles the tree window
          vim.cmd.packadd("nvim.undotree")
          vim.keymap.set("n", "<leader>U", "<cmd>Undotree<cr>", { desc = "Undotree" })
        '';
      };
    };

    home = {
      # vim.loader's bytecode cache keys a module on its mtime and size, and
      # every file in the store has mtime 1: a rebuilt config of the same size
      # (say, a theme's "soft" for "hard") would load stale. Drop it on each
      # activation.
      activation.nvimLuaCache = hmArgs.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run rm -rf $VERBOSE_ARG ${hmArgs.config.xdg.cacheHome}/nvim/luac
      '';

      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      shellAliases = {
        vim = "nvim";
        vimdiff = "nvim -d";
      };
    };
  };
}
