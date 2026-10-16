{ config, lib, ... }:
{
  # Logs straight into Hyprland at boot, since the disk unlock (YubiKey or
  # passphrase) already guards it; after a logout, tuigreet asks for the password.
  flake.modules.nixos.pc = nixosArgs: {
    services.greetd.settings.initial_session = {
      user = config.flake.meta.owner.username;
      command = "${lib.getExe nixosArgs.config.programs.uwsm.package} start hyprland-uwsm.desktop";
    };
  };
}
