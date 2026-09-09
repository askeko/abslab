{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      step = 5;
      pactl = lib.getExe' pkgs.pulseaudio "pactl";

      incVolArgs = d: [
        pactl
        "set-sink-volume"
        "@DEFAULT_SINK@"
        "${d}${toString step}%"
      ];
      muteVolArgs = [
        pactl
        "set-sink-mute"
        "@DEFAULT_SINK@"
        "toggle"
      ];

    in
    {
      programs.niri.settings.binds = {
        # Fn keys stay usable on the lock screen
        "XF86AudioLowerVolume" = {
          action.spawn = incVolArgs "-";
          allow-when-locked = true;
        };
        "XF86AudioRaiseVolume" = {
          action.spawn = incVolArgs "+";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action.spawn = muteVolArgs;
          allow-when-locked = true;
        };

        "Mod+Shift+Minus".action.spawn = incVolArgs "-";
        "Mod+Shift+Plus".action.spawn = incVolArgs "+";
        "Mod+Shift+M".action.spawn = muteVolArgs;
      };
    };
}
