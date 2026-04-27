{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      inherit (pkgs) rofimoji;
    in
    {
      home.packages = [ rofimoji ];
    };
}
