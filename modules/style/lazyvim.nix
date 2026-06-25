# LazyVim styling from flake.meta.theme
{ config, ... }:
let
  theme = config.flake.meta.theme;
  cs = theme.schemes.${theme.scheme}.lazyvim;
in
{
  flake.modules.homeManager.lazyvim = {
    programs.lazyvim.plugins.colorscheme = ''
      return {
        ${cs.spec theme.mode},
        { "LazyVim/LazyVim", opts = { colorscheme = "${cs.name}" } },
      }
    '';
  };
}
