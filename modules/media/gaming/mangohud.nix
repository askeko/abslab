{
  flake.modules.homeManager.gui = {
    programs.mangohud = {
      enable = true;
      settings = {
        gamemode = true;
        gpu_fan = true;
        gpu_temp = true;
        cpu_temp = true;
        cpu_power = true;
        vram = true;
        ram = true;
        show_fps_limit = true;
        fps = true;
      };
    };
    stylix.targets.mangohud.opacity.override = {
      popups = 0.6;
    };
  };
}
