{ config, ... }:
{
  configurations.nixos.lazarus.module = {
    imports = with config.flake.modules.nixos; [
      efi
      pc
      nvidia-gpu
      niri
    ];
  };
}
