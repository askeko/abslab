{
  flake.modules.homeManager.lazyvim.programs.lazyvim = {
    extras.editor.harpoon2.enable = true;

    # The harpoon2 extra with the old add/menu keys; <leader>1-9 jump to files
    # 1-9 as in the extra.
    plugins.harpoon = ''
      return {
        "ThePrimeagen/harpoon",
        keys = function(_, keys)
          keys = vim.tbl_filter(function(key)
            return key[1] ~= "<leader>H" and key[1] ~= "<leader>h"
          end, keys)
          table.insert(keys, {
            "<leader>a",
            function()
              require("harpoon"):list():add()
            end,
            desc = "Harpoon File",
          })
          table.insert(keys, {
            "<C-e>",
            function()
              local harpoon = require("harpoon")
              harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = "Harpoon Quick Menu",
          })
          return keys
        end,
      }
    '';
  };
}
