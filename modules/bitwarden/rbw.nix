{ config, lib, ... }:
{
  flake.modules.homeManager.base = hmArgs: {
    programs.rbw = {
      enable = true;
      settings = {
        email = config.flake.meta.owner.email;
        pinentry = hmArgs.config.pinentry;
        # Seconds the agent keeps the vault unlocked; any process running as
        # the user can read secrets while it is.
        lock_timeout = lib.mkDefault 900;
      };
    };
  };
}
