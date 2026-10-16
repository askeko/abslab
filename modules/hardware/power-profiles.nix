{ lib, ... }:
{
  # Noctalia's power widget and control center switch profiles through it;
  # games can run with `powerprofilesctl launch -p performance %command%`.
  flake.modules.nixos.pc.services.power-profiles-daemon.enable = lib.mkDefault true;
}
