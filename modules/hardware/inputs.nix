{
  flake.modules.homeManager.gui = {
    wayland.windowManager.hyprland.settings = {
      input = {
        # Focus window at mouse
        follow_mouse = 1;

        # Touchpad scroll direction
        touchpad = {
          natural_scroll = "true";
          tap-to-click = true;
        };

        # Set mouse acceleration (adaptive/flat/custom)
        accel_profile = "flat";
        # Set mouse sensitivity
        sensitivity = 0.2; # -1.0 - 1.0, 0 means no modification
      };

      cursor = {
        inactive_timeout = 2;
      };
    };
  };
}
