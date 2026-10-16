{
  # Hyprland uses `eu` for every keyboard by default (hardware/inputs.nix).
  configurations.nixos.lazarus.module = {
    services.xserver.xkb.layout = "eu";
  };
}
