{ config, ... }:
{
  configurations.nixos.lazarus.module = {
    home-manager.users.${config.flake.meta.owner.username} = {
      # No HDR/bitdepth under niri (HDR output is disabled upstream) — the
      # Samsung runs SDR, which also removes the hyprlock HDR-crash class.
      # Workspaces are dynamic per-monitor; no pinning equivalent needed.
      programs.niri.settings.outputs = {
        "Samsung Electric Company Odyssey G85SB H1AK500000" = {
          mode = {
            width = 3440;
            height = 1440;
            refresh = 174.962;
          };
          position = {
            x = 0;
            y = 0;
          };
          focus-at-startup = true;
        };
        "Acer Technologies XB271HU #ASOehCXoFYrd" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 165.000;
          };
          position = {
            x = -2560;
            y = 0;
          };
        };
      };
    };
  };
}
