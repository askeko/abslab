{ lib, withSystem, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      lockCommand = lib.getExe pkgs.hyprlock;
      dpms-all = withSystem pkgs.stdenv.hostPlatform.system (psArgs: psArgs.config.packages.dpms-all);
    in
    {
      home.packages = [ dpms-all ];

      services.swayidle = {
        enable = true;
        extraArgs = [ ]; # override default -w flag
        timeouts = [
          {
            timeout = 60 * 10;
            command = "${pkgs.procps}/bin/pidof hyprlock || ${lockCommand}";
          }
          {
            timeout = 60 * 11;
            command = "${lib.getExe dpms-all} off";
            resumeCommand = "${lib.getExe dpms-all} on";
          }
        ];
      };
    };
}
