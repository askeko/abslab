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
