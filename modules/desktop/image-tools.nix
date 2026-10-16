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

      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + SHIFT + P", app("${lib.getExe pkgs.hyprpicker} -a"), "Pick colour (hex to clipboard)")
      '';

      xdg.mimeApps.defaultApplications =
        [
          "image/png"
          "image/jpeg"
        ]
        |> map (lib.flip lib.nameValuePair [ "imv.desktop" ])
        |> lib.listToAttrs;
    };
}
