{ lib, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";

        # Previews: video thumbnails, PDFs, archives, SVGs and images/fonts.
        extraPackages = with pkgs; [
          ffmpeg
          poppler-utils
          _7zz
          resvg
          imagemagick
        ];
      };
    };

  # Noctalia colours: its community yazi template, vendored in yazi-noctalia/
  # (noctalia-dev/community-templates@d5bd193, yazi/) without its apply.sh hook,
  # which would edit theme.toml; the flavor is selected here instead.
  flake.modules.homeManager.gui = {
    programs.noctalia.settings.theme.templates.user = {
      yazi = {
        input_path = lib.mkDefault "${./yazi-noctalia/yazi.toml}";
        output_path = lib.mkDefault "$XDG_CONFIG_HOME/yazi/flavors/noctalia.yazi/flavor.toml";
      };
      yazi_syntax = {
        input_path = lib.mkDefault "${./yazi-noctalia/yazi.tmTheme}";
        output_path = lib.mkDefault "$XDG_CONFIG_HOME/yazi/flavors/noctalia.yazi/tmtheme.xml";
      };
    };

    programs.yazi.theme.flavor = {
      dark = lib.mkDefault "noctalia";
      light = lib.mkDefault "noctalia";
    };
  };
}
