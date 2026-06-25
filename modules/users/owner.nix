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
          uid = 1001; # pinned so it survives a reinstall (and external drives can match it)
        };

        nix.settings.trusted-users = [ config.flake.meta.owner.username ];
      };
    };
  };
}
