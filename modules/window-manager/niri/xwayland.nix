{
  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        xwayland-satellite
      ];
    };
}
