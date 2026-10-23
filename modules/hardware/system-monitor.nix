{ inputs, lib, ... }:
{
  flake.modules.homeManager.base = {
    programs.btop = {
      enable = true;
      settings.color_theme = lib.mkDefault "rose-pine";
    };
    # Rosé Pine's btop port. Not programs.btop.themes, which writes a string
    # (as the input's path is) as the theme's text.
    xdg.configFile."btop/themes/rose-pine.theme".source = "${inputs.rose-pine-btop}/rose-pine.theme";
  };
}
