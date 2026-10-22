{ lib, ... }:
{
  # Discord through Vesktop (Discord's web app with Vencord built in). Unlike
  # the official client, its webcam goes through Chromium's WebRTC, so with the
  # PipeWire camera it shows up in Noctalia's privacy widget.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      programs.vesktop = {
        enable = true;
        # Overridable, since the HM module overrides the package (withSystemVencord).
        package = lib.mkDefault (
          lib.makeOverridable (
            args:
            pkgs.symlinkJoin {
              name = "vesktop";
              paths = [ (pkgs.vesktop.override args) ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/vesktop --add-flags --enable-features=WebRtcPipeWireCamera
              '';
            }
          ) { }
        );
      };
    };
}
