{
  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
      };
    };
}
