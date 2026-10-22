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

      # Noctalia colours: the System24 style of its community discord template,
      # vendored in vesktop-noctalia/ (noctalia-dev/community-templates@a38fc33,
      # discord/). It imports System24's base CSS from refact0r.github.io at
      # start. Enabled once in Vesktop's Settings -> Themes: declaring it in
      # Home Manager would make all of Vencord's settings read-only.
      programs.noctalia.settings.theme.templates.user.vesktop = {
        input_path = lib.mkDefault "${./vesktop-noctalia/discord-system24.css}";
        output_path = lib.mkDefault "$XDG_CONFIG_HOME/vesktop/themes/noctalia-system24.theme.css";
      };
    };
}
