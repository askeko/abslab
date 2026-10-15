{
  flake.modules.homeManager.lazyvim =
    { pkgs, ... }:
    {
      programs.lazyvim = {
        extras = {
          lang.nix.enable = true;
        };

        # What LazyVim's nix extra calls: nil_ls (LSP), statix (nvim-lint),
        # nixfmt (conform) — matches `just lint` / `just fmt`.
        extraPackages = with pkgs; [
          nil
          statix
          nixfmt
        ];
      };
    };
}
