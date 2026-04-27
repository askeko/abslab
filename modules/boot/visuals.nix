{
  flake.modules.nixos = {
    base = {
      boot.kernelParams = [
        "quiet"
        "systemd.show_status=error"
      ];
    };
    pc = {
      boot.plymouth.enable = true;
    };
  };
}
