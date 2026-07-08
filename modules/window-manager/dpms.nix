{
  perSystem =
    { pkgs, ... }:
    {
      packages.dpms-all = pkgs.writeShellApplication {
        name = "dpms-all";
        runtimeInputs = [
          pkgs.niri
        ];
        text = ''
          if [ $# -ne 1 ]; then
              echo "Usage: $0 [on|off]" >&2
              exit 1
          fi
          if [ "$1" != "on" ] && [ "$1" != "off" ]; then
              echo "Usage: $0 [on|off]" >&2
              exit 1
          fi
          niri msg action "power-$1-monitors"
        '';
      };
    };
}
