{ inputs, lib, ... }:
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

        # Rosé Pine's yazi port.
        flavors.rose-pine = "${inputs.rose-pine-yazi}/flavors/rose-pine.yazi";
        theme.flavor = {
          dark = lib.mkDefault "rose-pine";
          light = lib.mkDefault "rose-pine";
        };
      };
    };
}
