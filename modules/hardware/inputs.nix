{ lib, ... }:
{
  flake.modules.homeManager.gui.wayland.windowManager.hyprland.settings.config =
    lib.mapAttrsRecursive (_: lib.mkDefault)
      {
        input = {
          # Default for every keyboard; hosts override it per device.
          kb_layout = "eu";

          follow_mouse = 1;
          accel_profile = "flat";
          sensitivity = 0.2;

          touchpad = {
            natural_scroll = true;
            tap_to_click = true;
          };
        };

        cursor.inactive_timeout = 2; # seconds
      };
}
