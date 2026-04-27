# modules/window-manager/niri/greetd.nix
{ lib, config, ... }:
{
  flake.modules.nixos.niri =
    nixosArgs@{ pkgs, ... }:
    {
      services.greetd.settings = {
        initial_session = {
          user = config.flake.meta.owner.username;
          command = "${nixosArgs.config.programs.niri.package}/bin/niri-session";
        };
        default_session.command =
          [
            (lib.getExe pkgs.tuigreet)
            "--cmd"
            "${nixosArgs.config.programs.niri.package}/bin/niri-session"
            "--remember"
          ]
          |> lib.concatStringsSep " ";
      };
    };
}
