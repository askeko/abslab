let
  mode = "privacy";
in
{
  perSystem =
    { pkgs, ... }:
    {
      # Manual privacy toggles for screencasts — niri's event stream has no
      # screencast event (see todo.md for the automatic D-Bus approach).
      packages = {
        notification-privacy-off = pkgs.writeShellApplication {
          name = "notification-privacy-off";
          runtimeInputs = [ pkgs.mako ];
          text = ''
            makoctl mode -r ${mode}
          '';
        };
        notification-privacy-on = pkgs.writeShellApplication {
          name = "notification-privacy-on";
          runtimeInputs = [ pkgs.mako ];
          text = ''
            makoctl mode -a ${mode}
          '';
        };
      };
    };

  flake.modules.homeManager.gui = {
    services.mako = {
      enable = true;
      settings = {
        anchor = "top-right";
        default-timeout = 3000;
        ignore-timeout = 1;
        "mode=${mode}".invisible = 1;
      };
    };
    services.systembus-notify.enable = true;
  };
}
