{ config, ... }:
{
  # halflight's screen and the ones it gets plugged into. Monitors match by
  # description prefix (make + model, see `hyprctl monitors`).
  configurations.nixos.halflight.module = {
    home-manager.users.${config.flake.meta.owner.username}.wayland.windowManager.hyprland.settings.monitor =
      [
        {
          output = "eDP-1";
          mode = "preferred";
          position = "0x0";
          scale = 1;
        }
        {
          output = "desc:Lenovo Group Limited P27q-20";
          mode = "preferred";
          position = "1920x0";
          scale = 1;
        }
        {
          output = "desc:Synaptics Inc Non-PnP 0x00BC614E";
          mode = "3440x1440";
          position = "4480x0";
          scale = 1;
        }
        {
          output = "desc:Dell Inc. DELL";
          mode = "3440x1440";
          position = "auto";
          scale = 1;
        }
        # Anything else (projectors, borrowed screens) mirrors the laptop screen.
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
          mirror = "eDP-1";
        }
      ];
  };
}
