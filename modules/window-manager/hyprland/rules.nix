{
  flake.modules.homeManager.gui.wayland.windowManager.hyprland.settings.window_rule = [
    # Apps asking to be maximized would take the whole width of the scrolling
    # layout; Mod+F does that on request instead.
    {
      name = "suppress-maximize-events";
      match.class = ".*";
      suppress_event = "maximize";
    }
    # From Hyprland's example config: fixes dragging in some XWayland apps.
    {
      name = "fix-xwayland-drags";
      match = {
        class = "^$";
        title = "^$";
        xwayland = true;
        float = true;
        fullscreen = false;
        pin = false;
      };
      no_focus = true;
    }
  ];
}
