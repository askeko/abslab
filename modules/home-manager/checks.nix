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
      stylixStub = {
        stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        stylix.polarity = "dark";
        stylix.image = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
        stylix.targets.waybar.enable = false;
        stylix.targets.neovim.enable = false;
        stylix.targets.hyprlock.enable = false;
        stylix.targets.firefox.profileNames = [ "primary" ];
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
