{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        exiftool
        gimp-with-plugins
        hyprpicker
        imagemagick
        imv
        inkscape
        jpeginfo
      ];

      # imv has no include, so Noctalia renders its whole config from
      # imv-noctalia/config (background and overlay colours); other imv
      # settings go in that file too, not in programs.imv.
      programs.noctalia.settings.theme.templates.user.imv = {
        input_path = lib.mkDefault "${./imv-noctalia/config}";
        output_path = lib.mkDefault "$XDG_CONFIG_HOME/imv/config";
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
