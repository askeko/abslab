{ lib, ... }:
{
  flake.modules.nixos.pc =
    nixosArgs@{ pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        settings.default_session.command =
          [
            (lib.getExe pkgs.tuigreet)
            "--cmd"
            "'${lib.getExe nixosArgs.config.programs.uwsm.package} start hyprland-uwsm.desktop'"
            "--remember"
          ]
          |> lib.concatStringsSep " ";
      };
    };
}
