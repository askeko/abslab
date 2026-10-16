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
          hyprland.enable = false;
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
          ];
          laptop = with config.flake.modules.homeManager; [
            base
            gui
            stylix
            stylixStub
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
