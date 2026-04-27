{
  flake.modules.homeManager.lazyvim =
    { pkgs, ... }:
    {
      programs.lazyvim = {

        extras = {
          lang.python.enable = true;
        };

        extraPackages = with pkgs; [
          lua-language-server
          pyright
          ruff
        ];
      };
    };
}
