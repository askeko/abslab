{
  flake.modules.homeManager.gui = {
    # Cursor theme/size come from the stylix target.
    programs.niri.settings = {
      input = {
        focus-follows-mouse.enable = true;
        touchpad = {
          natural-scroll = true;
          tap = true;
        };
        mouse = {
          accel-profile = "flat";
          accel-speed = 0.2;
        };
      };
      cursor.hide-after-inactive-ms = 2000;
    };
  };
}
