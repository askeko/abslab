{
  inputs,
  config,
  lib,
  ...
}:
let
  owner = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.base = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      # Encrypted secrets live in the repo and are decrypted at activation.
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      # Default key location (current system / non-impermanence hosts). The
      # impermanence module overrides this to the /persist copy on hosts that
      # opt in, so the key survives the root wipe. mkDefault lets it do that
      # without mkForce.
      age.keyFile = lib.mkDefault "/var/lib/sops-nix/key.txt";
    };

    # User login/lock password hash. `neededForUsers` makes it available early
    # enough to back users.users.<name>.hashedPasswordFile (see users/owner.nix).
    # This is also REQUIRED under impermanence: an imperatively-set or empty
    # password would be wiped on every boot; a declarative hash survives.
    sops.secrets."users/${owner}/hashed-password".neededForUsers = true;
  };
}
