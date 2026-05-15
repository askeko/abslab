{
  flake.modules.homeManager.gui =
    hmArgs:
    let
      wallpaper = "${hmArgs.config.home.homeDirectory}/pictures/wallpapers/slick/apple-dark.jpg";
    in
    {
      wayland.windowManager.hyprland.settings.misc.disable_hyprland_logo = true;

      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          preload = [ wallpaper ];
          wallpaper = [
            {
              monitor = "";
              path = wallpaper;
              fit_mode = "stretch";
            }
          ];
        };
      };
    };
}
