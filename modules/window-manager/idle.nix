{ lib, withSystem, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      lockCommand = lib.getExe pkgs.hyprlock;
      dpms-all = withSystem pkgs.stdenv.hostPlatform.system (psArgs: psArgs.config.packages.dpms-all);
      # Idempotent lock: don't spawn a second hyprlock if one is already up.
      lockIfNeeded = "${pkgs.procps}/bin/pidof hyprlock || ${lockCommand}";
    in
    {
      home.packages = [ dpms-all ];

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            # Run hyprlock on the logind `Lock` signal. This is what makes
            # `loginctl lock-session` actually lock — and that's what the YubiKey
            # auto-lock-on-removal udev rule (security/yubikey.nix) fires, so the
            # session now locks when the key is unplugged. Also locks on suspend.
            lock_cmd = lockIfNeeded;
            before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
            after_sleep_cmd = "${lib.getExe dpms-all} on";
          };

          listener = [
            {
              timeout = 60 * 10; # lock after 10 min idle
              on-timeout = lockIfNeeded;
            }
            {
              timeout = 60 * 11; # screens off 1 min after the lock
              on-timeout = "${lib.getExe dpms-all} off";
              on-resume = "${lib.getExe dpms-all} on";
            }
          ];
        };
      };
    };
}
