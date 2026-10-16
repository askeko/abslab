{ lib, ... }:
{
  flake.modules.homeManager = {
    base.programs.btop.enable = true;

    # Colours rendered by Noctalia's btop template.
    gui = {
      programs.btop.settings.color_theme = lib.mkDefault "noctalia";
      programs.noctalia.settings.theme.templates.builtin_ids = [ "btop" ];
    };
  };
}
