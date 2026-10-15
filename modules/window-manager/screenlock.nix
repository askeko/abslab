{ lib, ... }:
{
  # Noctalia's lock screen authenticates against the `login` PAM service (see
  # security/yubikey.nix) and also locks on logind's Lock signal.
  flake.modules.homeManager.gui = hmArgs: {
    programs.noctalia.settings.lockscreen = {
      lock_before_suspend = lib.mkDefault true;
      fingerprint = lib.mkDefault false;
    };

    programs.niri.settings.binds."Mod+Alt+L".action.spawn = [
      (lib.getExe hmArgs.config.programs.noctalia.package)
      "msg"
      "session"
      "lock"
    ];
  };
}
