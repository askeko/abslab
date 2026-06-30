{ config, ... }:
let
  owner = config.flake.meta.owner.username;
in
{
  flake = {
    meta.owner = {
      email = "askeklitgaard@gmail.com";
      name = "Aske Klitgaard Ottesen";
      username = "absentia";
    };

    modules.nixos.base =
      { config, ... }:
      {
        users.users.${owner} = {
          isNormalUser = true;
          # Password hash is provisioned by sops-nix (see security/sops.nix).
          # `neededForUsers` on that secret makes it available in time.
          hashedPasswordFile = config.sops.secrets."users/${owner}/hashed-password".path;
          uid = 1000; # pinned so it stays stable across reinstalls
        };

        nix.settings.trusted-users = [ owner ];
      };
  };
}
