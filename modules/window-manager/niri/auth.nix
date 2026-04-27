{
  flake.modules.homeManager.niri = {
    services = {
      polkit-gnome.enable = true;
      gnome-keyring.enable = true;
    };
  };
}
