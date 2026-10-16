{ lib, ... }:
{
  # Noctalia's lock screen authenticates against the `login` PAM service (see
  # security/yubikey.nix) and also locks on logind's Lock signal.
  flake.modules.homeManager.gui = {
    programs.noctalia.settings.lockscreen = {
      lock_before_suspend = lib.mkDefault true;
      fingerprint = lib.mkDefault false;
    };

    wayland.windowManager.hyprland.extraConfig = ''
      bind(mod .. " + ALT + L", cmd(ipc .. "session lock"), "Lock screen")
    '';
  };
}
