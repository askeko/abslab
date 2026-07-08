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
            (lib.getExe' nixosArgs.config.programs.niri.package "niri-session")
            "--remember"
          ]
          |> lib.concatStringsSep " ";
      };
    };
}
