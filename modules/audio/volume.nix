{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      step = 5;
      pactl = lib.getExe' pkgs.pulseaudio "pactl";

      incVol =
        d:
        lib.concatStringsSep " " [
          pactl
          "set-sink-volume @DEFAULT_SINK@ ${d}${toString step}%"
        ];

      muteVol = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";

    in
    {
      wayland.windowManager.hyprland.settings.bind = [
        # Set volume with fn keys
        ",XF86AudioLowerVolume, exec, ${incVol "-"}"
        ",XF86AudioRaiseVolume, exec, ${incVol "+"}"
        ",XF86AudioMute, exec, ${muteVol}"

        # Set volume
        "SUPER+SHIFT, minus, exec, ${incVol "-"}"
        "SUPER+SHIFT, plus, exec, ${incVol "+"}"
        "SUPER+SHIFT, m, exec, ${muteVol}"
      ];
    };
}
