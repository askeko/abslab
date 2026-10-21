{ lib, ... }:
{
  # NVIDIA's open kernel module (Turing and newer), like Arch's `nvidia-open`.
  # Modesetting (needed by Wayland compositors) and nvidia-settings are on by
  # default; 32-bit graphics for games come from programs.steam.
  flake.modules.nixos.nvidia-gpu = {
    hardware.graphics.enable = lib.mkDefault true;
    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
    hardware.nvidia.open = lib.mkDefault true;

    nixpkgs.config.allowUnfreePackages = [
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-x11"
    ];
  };
}
