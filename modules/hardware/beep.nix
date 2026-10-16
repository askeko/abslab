{
  # No beep.
  flake.modules.nixos.pc.boot.blacklistedKernelModules = [ "pcspkr" ];
}
