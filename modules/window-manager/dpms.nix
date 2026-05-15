{
  perSystem =
    { pkgs, ... }:
    {
      packages.dpms-all = pkgs.writeShellApplication {
        name = "dpms-all";
        runtimeInputs = [ pkgs.hyprland ];
        text = ''
          if [ $# -ne 1 ]; then
              echo "Usage: $0 [on|off]" >&2
              exit 1
          fi
          if [ "$1" != "on" ] && [ "$1" != "off" ]; then
              echo "Usage: $0 [on|off]" >&2
              exit 1
          fi
          hyprctl dispatch dpms "$1"
        '';
      };
    };

  flake.modules.nixos.pc = {
    services.kmscon.extraConfig = ''
      dpms-timeout=60
    '';
  };
}
