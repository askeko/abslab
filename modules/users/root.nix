{
  flake.modules.nixos.base =
    { config, ... }:
    {
      users.users.root.hashedPasswordFile = config.sops.secrets."users/root/hashed-password".path;
    };
}
