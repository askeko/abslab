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

  # NOTE: the old `services.kmscon.extraConfig = "dpms-timeout=60"` block is left
  # out on purpose — kmscon isn't enabled here, and `services.kmscon.config` was
  # removed upstream (see style/theme.nix). It only set the *text-console* blank
  # timeout, which is unrelated to the Wayland idle/lock handled in idle.nix.
}
