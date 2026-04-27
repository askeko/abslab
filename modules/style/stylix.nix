{ inputs, ... }:
let
  polyModule = {
    stylix = {
      enable = true;
      enableReleaseChecks = false;
    };
  };
in
{
  flake.modules = {
    nixos.base = {
      imports = [
        inputs.stylix.nixosModules.stylix
        polyModule
      ];
      stylix.homeManagerIntegration.autoImport = false;
    };

    homeManager.base = {
      imports = [
        inputs.stylix.homeModules.stylix
        polyModule
      ];
    };
  };
}
