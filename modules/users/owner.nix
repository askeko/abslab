{ config, ... }:
{
  flake = {
    meta.owner = {
      email = "askeklitgaard@gmail.com";
      name = "Aske Klitgaard Ottesen";
      username = "absentia";
    };

    modules = {
      nixos.base = {
        users.users.${config.flake.meta.owner.username} = {
          isNormalUser = true;
          initialPassword = "";
        };

        nix.settings.trusted-users = [ config.flake.meta.owner.username ];
      };
    };
  };
}
