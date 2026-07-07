{ config, lib, withSystem, ... }:
let
  username = config.flake.meta.owner.username;
  # Samsung Odyssey G85SB runs HDR+10-bit; hyprlock crashes on this surface under
  # NVIDIA/Wayland. Strip the HDR flags before locking and restore them on EXIT
  # (EXIT trap fires even when hyprlock itself crashes, so HDR always comes back).
  samsungBase = "desc:Samsung Electric Company Odyssey G85SB H1AK500000,3440x1440@174.96Hz,0x0,1";
  samsungHdr = "${samsungBase},bitdepth, 10, cm, hdr";
in
{
  configurations.nixos.lazarus.module = {
    home-manager.users.${username} =
      { pkgs, ... }:
      let
        dpms-all = withSystem pkgs.stdenv.hostPlatform.system (
          psArgs: psArgs.config.packages.dpms-all
        );
        lockCommand = lib.getExe (pkgs.writeShellApplication {
          name = "hyprlock-hdr-safe";
          text = ''
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "${samsungBase}"
            trap '${pkgs.hyprland}/bin/hyprctl keyword monitor "${samsungHdr}"' EXIT
            ${lib.getExe pkgs.hyprlock}
          '';
        });
        lockIfNeeded = "${pkgs.procps}/bin/pidof hyprlock || ${lockCommand}";
      in
      {
        services.hypridle.settings.general.lock_cmd = lib.mkForce lockIfNeeded;
        services.hypridle.settings.listener = lib.mkForce [
          {
            timeout = 60 * 10;
            on-timeout = lockIfNeeded;
          }
          {
            timeout = 60 * 11;
            on-timeout = "${lib.getExe dpms-all} off";
            on-resume = "${lib.getExe dpms-all} on";
          }
        ];
        # unbind removes the raw-hyprlock bind from screenlock.nix (processed first via
        # settings), then the new bind replaces it with the HDR-safe wrapper.
        wayland.windowManager.hyprland.extraConfig = ''
          unbind = SUPER+ALT, l
          bind = SUPER+ALT, l, exec, ${lockCommand}
        '';
      };
  };
}
