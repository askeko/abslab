{ config, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake = {
    meta.accounts.github = {
      domain = "github.com";
      username = "askeko";
    };

    modules = {
      nixos.base = {
        # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
        programs.ssh.knownHosts."github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

        sops.secrets."github/ssh-private-key" = {
          owner = username;
          mode = "0600";
        };
      };

      homeManager = {
        base =
          { pkgs, osConfig, ... }:
          {
            programs.gh = {
              package = pkgs.gh.overrideAttrs (oldAttrs: {
                buildInputs = oldAttrs.buildInputs or [ ] ++ [ pkgs.makeWrapper ];
                postInstall = oldAttrs.postInstall or "" + ''
                  wrapProgram $out/bin/gh --unset GITHUB_TOKEN
                '';
              });
              enable = true;
              settings.git_protocol = "ssh";
            };

            programs.git.settings.core.sshCommand = "ssh -i ${
              osConfig.sops.secrets."github/ssh-private-key".path
            } -o IdentitiesOnly=yes";

            home.packages = with pkgs; [ gh-dash ];
          };
        gui =
          { pkgs, ... }:
          {
            home.packages = with pkgs; [ gh-markdown-preview ];
          };
      };
    };
  };
}
