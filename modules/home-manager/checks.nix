{
  config,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      # Stand-in for the host config that HM modules read via osConfig.
      osConfigStub = {
        sops.secrets."github/ssh-private-key".path = "/run/secrets/github/ssh-private-key";
      };
    in
    {
      checks =
        {
          base = with config.flake.modules.homeManager; [ base ];
          gui = with config.flake.modules.homeManager; [
            base
            gui
          ];
          laptop = with config.flake.modules.homeManager; [
            base
            gui
            laptop
          ];
        }
        |> lib.mapAttrs' (
          name: modules: {
            name = "home-manager/${name}";
            value =
              {
                inherit pkgs;
                extraSpecialArgs.osConfig = osConfigStub;
                modules = modules ++ [ { home.stateVersion = "26.05"; } ];
              }
              |> inputs.home-manager.lib.homeManagerConfiguration
              |> lib.getAttrFromPath [
                "config"
                "home-files"
              ];
          }
        );
    };
}
