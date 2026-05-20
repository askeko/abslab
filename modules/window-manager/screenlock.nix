{ lib, ... }:
{
  flake.modules.nixos.pc = {
    security.pam.services.hyprlock = { };
  };

  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      lockCommand = lib.getExe pkgs.hyprlock;
    in
    {
      wayland.windowManager.hyprland.settings.bind = [
        "SUPER+ALT, l, exec, ${lockCommand}"
      ];

      programs.hyprlock = {
        enable = true;
        settings = {

          background = [
            {
              monitor = "";
              path = "~/pictures/wallpapers/slick/car_on_mars.jpg";
            }
          ];

          input-field = [
            {
              monitor = "";
              size = "200, 50";
              outline_thickness = 3;
              dots_size = 0.33;
              dots_spacing = 0.15;
              dots_center = false;
              dots_rounding = -1;
              fade_on_empty = false;
              fade_timeout = 1000;
              placeholder_text = "<i>Input Password...</i>";
              hide_input = false;
              rounding = -1;
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
              capslock_color = -1;
              numlock_color = -1;
              bothlock_color = -1;
              invert_numlock = false;
              swap_font_color = false;

              position = "0, -20";
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            {
              monitor = "";
              text = "$ATTEMPTS $FAIL";
              text_align = "center";
              font_size = 40;
              font_family = "";
              rotate = 0;

              position = "0, -90";
              halign = "center";
              valign = "center";
            }

            {
              monitor = "";
              text = "$TIME";
              text_align = "center";
              font_size = 110;
              font_family = "";
              rotate = 0;

              position = "650, -300";
              halign = "center";
              valign = "center";
            }

            {
              monitor = "";

              text = ''cmd[update:3600000] echo "<span foreground='##c0caf5'>$(${pkgs.coreutils}/bin/date +"%a, %d. %b %Y")</span>"'';
              text_align = "center";
              font_size = 60;
              font_family = "";
              rotate = 0;

              position = "550, -400";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
}
