{ config, ... }:
{
  configurations.nixos.halflight.module = {
    imports = with config.flake.modules.nixos; [
      efi
      pc
      niri
    ];
  };
}
