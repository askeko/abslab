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
      stylix = inputs.stylix.homeModules.stylix;
      # In real systems niri-flake's NixOS module injects these via
      # home-manager.sharedModules; standalone checks need them explicitly.
      # Pinning the package makes the build-time KDL validation run against
      # the same niri the hosts use (default would be niri-flake's older build).
      niri = inputs.niri.homeModules.config;
      niriStub =
        { pkgs, ... }:
        {
          imports = [ inputs.niri.homeModules.stylix ];
          programs.niri.package = pkgs.niri;
        };
      # Stand-in for the host config that HM modules read via osConfig.
      osConfigStub = {
        sops.secrets."github/ssh-private-key".path = "/run/secrets/github/ssh-private-key";
      };
      stylixStub.stylix = {
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
        image = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
        targets = {
          neovim.enable = false;
          noctalia.enable = false;
          firefox.profileNames = [ "primary" ];
        };
      };
    in
    {
      checks =
        {
          base = with config.flake.modules.homeManager; [ base ];
          gui = with config.flake.modules.homeManager; [
            base
            gui
            stylix
            stylixStub
            niri
            niriStub
          ];
          laptop = with config.flake.modules.homeManager; [
            base
            gui
            stylix
            stylixStub
            niri
            niriStub
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
