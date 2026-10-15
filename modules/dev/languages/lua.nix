{
  # LazyVim core configures lua_ls itself (there is no lang.lua extra); it only
  # needs the server on PATH.
  flake.modules.homeManager.lazyvim =
    { pkgs, ... }:
    {
      programs.lazyvim.extraPackages = with pkgs; [
        lua-language-server
      ];
    };
}
