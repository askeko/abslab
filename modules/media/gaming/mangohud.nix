{
  flake.modules.homeManager.gui = {
    programs.mangohud.enable = true;

    # Text rather than programs.mangohud.settings: the HUD shows its items in
    # the file's order, which an attribute set would sort.
    xdg.configFile."MangoHud/MangoHud.conf".text = ''
      gamemode
      gpu_fan
      gpu_temp
      cpu_temp
      cpu_power
      vram
      ram
      show_fps_limit
      fps

      background_alpha=0.6
    '';
  };
}
