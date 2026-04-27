{
  flake.modules.nixos.nvidia-gpu = {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Modesetting is required for most Wayland compositors
      modesetting.enable = true;

      # Use the open source kernel module (for Turing+ GPUs)
      # Set to false if you have an older GPU or run into issues
      open = true;

      # Enable the settings menu (nvidia-settings)
      nvidiaSettings = true;

    };

    nixpkgs.config.allowUnfreePackages = [
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-x11"
    ];
  };
}
