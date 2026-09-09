{ config, lib, ... }:
{
  flake.modules.nixos.pc = nixosArgs: {
    services.greetd.settings.initial_session = {
      user = config.flake.meta.owner.username;
      command = lib.getExe' nixosArgs.config.programs.niri.package "niri-session";
    };
  };
}
