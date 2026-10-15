{ lib, ... }:
{
  flake.modules.nixos.pc = {
    # Battery and power devices in the bar.
    services.upower.enable = lib.mkDefault true;

    # niri-flake starts its own polkit agent; Noctalia's replaces it.
    systemd.user.services.niri-flake-polkit.enable = lib.mkDefault false;
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

      programs.niri.settings.binds = {
        "Mod+S".action.spawn = [
          noctalia
          "msg"
          "panel-toggle"
          "control-center"
        ];
        "Mod+Apostrophe".action.spawn = [
          noctalia
          "msg"
          "settings-toggle"
        ];
        "Mod+Shift+Q".action.spawn = [
          noctalia
          "msg"
          "panel-toggle"
          "session"
        ];
        "Alt+Tab".action.spawn = [
          noctalia
          "msg"
          "window-switcher"
          "hold"
        ];
      };
    };
}
