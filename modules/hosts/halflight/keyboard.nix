{ config, ... }:
{
  configurations.nixos.halflight.module = {
    services.xserver.xkb = {
      layout = "dk";
      options = "caps:swapescape";
    };

    # The built-in keyboard is dk; external ones keep the `eu` default.
    # resolve_binds_by_sym makes binds follow the keys printed on it.
    home-manager.users.${config.flake.meta.owner.username}.wayland.windowManager.hyprland.settings.device =
      [
        {
          name = "at-translated-set-2-keyboard";
          kb_layout = "dk";
          kb_options = "caps:swapescape";
          resolve_binds_by_sym = true;
        }
      ];
  };
}
