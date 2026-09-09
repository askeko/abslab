{ pkgs, ... }:
{
  packages = with pkgs; [
    just
    statix
    deadnix
    nixfmt-rfc-style
  ];
}
