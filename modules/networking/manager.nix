{
  flake.modules = {
    nixos.pc =
      { lib, ... }:
      let
        # Sops-encrypted iwd network profiles. Drop a `sops -e`-encrypted
        # <SSID>.psk in secrets/iwd/ and it lands in /var/lib/iwd/ at
        # activation. Minimal profile:
        #   [Security]
        #   Passphrase=<wifi password>
        # SSIDs containing characters outside [A-Za-z0-9_-] must be
        # hex-encoded as =<hex(ssid)>.psk per iwd's naming rules.
        pskDir = ../../secrets/iwd;
        psks = lib.optionals (builtins.pathExists pskDir) (
          builtins.readDir pskDir |> builtins.attrNames |> builtins.filter (lib.hasSuffix ".psk")
        );
      in
      {
        networking = {
          wireless.iwd = {
            enable = true;
            settings = {
              IPv6.Enabled = true;
              Settings.AutoConnect = true;
            };
          };
          networkmanager.wifi.backend = "iwd";
        };

        sops.secrets =
          psks
          |> map (name: {
            name = "iwd/${name}";
            value = {
              format = "binary";
              sopsFile = pskDir + "/${name}";
              path = "/var/lib/iwd/${name}";
              restartUnits = [ "iwd.service" ];
            };
          })
          |> builtins.listToAttrs;
      };

    homeManager.base =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.impala ];
      };
  };
}
