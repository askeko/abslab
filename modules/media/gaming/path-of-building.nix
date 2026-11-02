{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        rusty-path-of-building
      ];
    };
}
