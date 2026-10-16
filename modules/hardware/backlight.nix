{
  flake.modules.homeManager.laptop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        brightnessctl
      ];

      # Through Noctalia, for its OSD. Also works on the lock screen.
      wayland.windowManager.hyprland.extraConfig = ''
        bind("XF86MonBrightnessUp", cmd(ipc .. "brightness-up"), "Brightness up", { locked = true, repeating = true })
        bind("XF86MonBrightnessDown", cmd(ipc .. "brightness-down"), "Brightness down", { locked = true, repeating = true })
      '';
    };
}
