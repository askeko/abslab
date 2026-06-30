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
