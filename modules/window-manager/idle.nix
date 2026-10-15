{ lib, ... }:
{
  # Lock after 10 minutes idle, screens off a minute later.
  flake.modules.homeManager.gui.programs.noctalia.settings.idle.behavior = {
    lock = {
      timeout = lib.mkDefault 600;
      action = lib.mkDefault "lock";
    };
    screen_off = {
      timeout = lib.mkDefault 660;
      action = lib.mkDefault "screen_off";
    };
  };
}
