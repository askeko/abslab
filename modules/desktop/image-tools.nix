{ config, lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        exiftool
        gimp-with-plugins
        hyprpicker
        imagemagick
        inkscape
        jpeginfo
      ];

      # Rosé Pine has no imv port: its base behind images.
      programs.imv = {
        enable = true;
        settings.options.background = lib.mkDefault (lib.removePrefix "#" config.flake.meta.rosePine.base);
      };

      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + SHIFT + P", app("${lib.getExe pkgs.hyprpicker} -a"), "Pick colour (hex to clipboard)")
      '';

      xdg.mimeApps.defaultApplications =
        [
          "image/png"
          "image/jpeg"
          "image/gif"
          "image/webp"
          "image/bmp"
          "image/tiff"
          "image/svg+xml"
        ]
        |> map (lib.flip lib.nameValuePair [ "imv.desktop" ])
        |> lib.listToAttrs;
    };
}
