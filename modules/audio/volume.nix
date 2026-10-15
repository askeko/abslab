{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs:
    let
      msg =
        args:
        [
          (lib.getExe hmArgs.config.programs.noctalia.package)
          "msg"
        ]
        ++ args;

      # Fn keys stay usable on the lock screen
      locked = args: {
        action.spawn = msg args;
        allow-when-locked = true;
      };
    in
    {
      programs.niri.settings.binds = {
        "XF86AudioLowerVolume" = locked [ "volume-down" ];
        "XF86AudioRaiseVolume" = locked [ "volume-up" ];
        "XF86AudioMute" = locked [ "volume-mute" ];

        "Mod+Shift+Minus".action.spawn = msg [ "volume-down" ];
        "Mod+Shift+Plus".action.spawn = msg [ "volume-up" ];
        "Mod+Shift+M".action.spawn = msg [ "volume-mute" ];

        "XF86AudioPlay" = locked [
          "media"
          "toggle"
        ];
        "XF86AudioPause" = locked [
          "media"
          "toggle"
        ];
        "XF86AudioNext" = locked [
          "media"
          "next"
        ];
        "XF86AudioPrev" = locked [
          "media"
          "previous"
        ];
      };
    };
}
