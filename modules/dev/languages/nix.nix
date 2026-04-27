{
  flake.modules.homeManager.lazyvim =
    { pkgs, ... }:
    {

      home.packages = with pkgs; [
        statix
      ];

      programs.lazyvim = {
        extras = {
          lang.nix.enable = true;
        };

        extraPackages = with pkgs; [
          nil # Nix lsp
          alejandra # Nix formatter
        ];
      };
    };
}
