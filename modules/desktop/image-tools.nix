{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, config, ... }:
    let
      c = config.lib.stylix.colors;
    in
    {
      # imv has no Stylix target.
      xdg.configFile."imv/config".text = ''
        [options]
        background = ${c.base00}
        overlay_text_color = ${c.base05}
        overlay_background_color = ${c.base01}
      '';

      home.packages = with pkgs; [
        exiftool
        gimp-with-plugins
        imagemagick
        imv
        inkscape
        jpeginfo
        wl-color-picker
      ];
      xdg.mimeApps.defaultApplications =
        [
          "image/png"
          "image/jpeg"
        ]
        |> map (lib.flip lib.nameValuePair [ "imv.desktop" ])
        |> lib.listToAttrs;
    };
}
