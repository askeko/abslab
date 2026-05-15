{ config, ... }:
{
  flake.modules.homeManager.base = hmArgs: {
    programs.rbw = {
      enable = true;
      settings = {
        email = config.flake.meta.owner.email;
        pinentry = hmArgs.config.pinentry;
      };
    };
  };
}
