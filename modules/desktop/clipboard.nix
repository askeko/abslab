{
  flake.modules.homeManager.gui =
    hmArgs@{
      lib,
      pkgs,
      ...
    }:
    {
      services.cliphist.enable = true;

      home.packages = with pkgs; [
        wl-clipboard-rs
      ];

      wayland.windowManager.hyprland.settings.bind =
        let
          rofi-cliphist = pkgs.writeShellApplication {
            name = "rofi-cliphist";
            runtimeInputs = [
              hmArgs.config.services.cliphist.package
              hmArgs.config.programs.rofi.package
            ];
            text = ''
              prompt=' 󰆏 '
              content=$(cliphist list | rofi -dmenu -p "$prompt")
              decoded=$(cliphist decode <<<"$content")

              echo "$decoded" | wl-copy
            '';
          };
        in
        [ "SUPER, p, exec, ${lib.getExe rofi-cliphist}" ];
    };
}
