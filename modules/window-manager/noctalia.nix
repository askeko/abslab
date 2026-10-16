{ lib, ... }:
{
  flake.modules.nixos.pc = {
    # Battery and power devices in the bar.
    services.upower.enable = lib.mkDefault true;

  };

  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      noctalia = lib.getExe hmArgs.config.programs.noctalia.package;
    in
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          theme = {
            mode = lib.mkDefault "dark";
            shell_mode = lib.mkDefault "follow";
            source = lib.mkDefault "builtin";
            builtin = lib.mkDefault "Tokyo-Night";
            # Feature modules add the apps they configure to builtin_ids.
            templates.enable_builtin_templates = lib.mkDefault true;
          };

          shell = {
            polkit_agent = lib.mkDefault true;
            # Apps started from the launcher get their own systemd scope.
            launch_apps_as_systemd_services = lib.mkDefault true;

            # Floating panels draw their own (glass) background; panels attached
            # to the bar take its background.
            panel = {
              transparency_mode = lib.mkDefault "glass";
              control_center_placement = lib.mkDefault "floating";
              control_center_position = lib.mkDefault "auto";
              wallpaper_placement = lib.mkDefault "floating";
              wallpaper_position = lib.mkDefault "auto";
              session_placement = lib.mkDefault "floating";
              session_position = lib.mkDefault "auto";
            };
          };

          location.auto_locate = lib.mkDefault true;
        };
      };

      # Noctalia finds its logind session (lock requests from the YubiKey
      # unplug rule, the polkit agent) through XDG_SESSION_ID, which the user
      # manager doesn't have.
      systemd.user.services.noctalia.Service.ExecStart =
        lib.mkForce "${pkgs.writeShellScript "noctalia" ''
          XDG_SESSION_ID=$(${lib.getExe' pkgs.systemd "loginctl"} show-user "$(${lib.getExe' pkgs.coreutils "id"} -un)" -p Display --value) exec ${noctalia}
        ''}";

      wayland.windowManager.hyprland = {
        # Noctalia (bar, launcher, notifications, lock screen) is controlled by
        # messages: binds use cmd(ipc .. "<command>").
        settings = {
          ipc._var = "${noctalia} msg ";

          # Noctalia's settings window floats.
          window_rule = [
            {
              match.class = "dev.noctalia.Noctalia";
              float = true;
              size = [
                1080
                920
              ];
            }
          ];

          # No Hyprland animations on Noctalia's own surfaces (bar, panels, OSD).
          layer_rule = [
            {
              name = "noctalia";
              match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
              no_anim = true;
              ignore_alpha = 0.5;
              blur = true;
              blur_popups = true;
            }
          ];
        };

        extraConfig = ''
          bind(mod .. " + S", cmd(ipc .. "panel-toggle control-center"), "Show Noctalia control center")
          bind(mod .. " + apostrophe", cmd(ipc .. "settings-toggle"), "Show settings menu")
          bind(mod .. " + SHIFT + Q", cmd(ipc .. "panel-toggle session"), "Power menu")
          bind("ALT + Tab", cmd(ipc .. "window-switcher hold"), "Window switcher")
          bind(mod .. " + SHIFT + S", cmd(ipc .. "theme-mode-toggle"), "Toggle light/dark theme")
        '';
      };
    };
}
