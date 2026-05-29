{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      # Bluetooth not working in current kernels.
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
