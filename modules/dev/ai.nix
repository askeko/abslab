{ lib, inputs, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.claude-code = {
        enable = lib.mkDefault true;
        # sadjow/claude-code-nix: updated hourly, unlike nixpkgs. The flake
        # instantiates its own pkgs with allowUnfree, so no allowlist entry needed.
        package = lib.mkDefault inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      };
    };
}
