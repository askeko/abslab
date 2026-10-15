{ lib, ... }:
{
  flake.modules.homeManager.gui = {
    programs.noctalia.settings.notification = {
      position = lib.mkDefault "top_right";
      follow_focused_output = lib.mkDefault true;
    };

    services.systembus-notify.enable = true;
  };
}
