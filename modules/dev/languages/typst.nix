{
  flake.modules.homeManager.lazyvim =
    { pkgs, ... }:
    {
      programs.lazyvim = {
        extras.lang.typst.enable = true;

        # What LazyVim's typst extra calls: tinymist (LSP, and the server
        # typst-preview runs), typstyle (conform), websocat (typst-preview's
        # connection to tinymist, otherwise downloaded at runtime).
        extraPackages = with pkgs; [
          tinymist
          typstyle
          websocat
        ];

        # Live PDF preview in Zathura: tinymist rewrites file.pdf next to
        # file.typ on every edit and Zathura reloads it; <leader>cz opens it
        # with the default PDF viewer. <leader>cp keeps the browser preview.
        plugins.typst = ''
          return {
            {
              "neovim/nvim-lspconfig",
              opts = { servers = { tinymist = { settings = { exportPdf = "onType" } } } },
            },
            {
              "chomosuke/typst-preview.nvim",
              opts = { dependencies_bin = { websocat = "websocat" } },
              keys = {
                {
                  "<leader>cz",
                  function()
                    vim.ui.open(vim.fn.expand("%:p:r") .. ".pdf")
                  end,
                  ft = "typst",
                  desc = "Open PDF (live, in the PDF viewer)",
                },
              },
            },
          }
        '';
      };
    };
}
