{
  flake.modules.homeManager = {
    base =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.bitwarden-cli ];
      };

    gui =
      { pkgs, ... }:
      {
        # bitwarden-desktop disabled: pins electron_39 (39.8.10) which is EOL/insecure.
        # Re-enable once upstream nixpkgs bumps the electron version.
        # home.packages = [ pkgs.bitwarden-desktop ];
      };
  };
}
