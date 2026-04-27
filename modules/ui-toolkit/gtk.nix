{
  flake.modules.homeManager = {
    base = {
      gtk.gtk4.theme = null;
    };
    gui = {
      gtk.enable = true;
    };
  };
}
