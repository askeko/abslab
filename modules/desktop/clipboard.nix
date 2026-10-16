{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        wl-clipboard-rs
      ];

      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + P", cmd(ipc .. "panel-toggle clipboard"), "Clipboard history")
      '';
    };
}
