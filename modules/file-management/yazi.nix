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
}
