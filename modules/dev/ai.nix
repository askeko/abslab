{
  lib,
  inputs,
  config,
  ...
}:
let
  unfreePackages = config.nixpkgs.config.allowUnfreePackages;
in
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    let
      # WARN:
      # Temporary pin: nixos-unstable still ships claude-code 2.1.278, and
      # Opus 5.5 needs 2.1.280+. Drop this (and the `nixpkgs-claude-code` flake
      # input) once the channel has the bump.
      pinned = import inputs.nixpkgs-claude-code {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
      };
    in
    {
      programs.claude-code = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pinned.claude-code;
      };
    };

  nixpkgs.config.allowUnfreePackages = [
    "claude-code"
  ];
}
