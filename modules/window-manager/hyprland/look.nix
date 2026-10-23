{ lib, ... }:
{
  flake.modules.homeManager.gui = {
    wayland.windowManager.hyprland.settings = {
      config = lib.mapAttrsRecursive (_: lib.mkDefault) {
        general = {
          layout = "scrolling";

          # Windows 5px apart; 15px at the sides so the neighbouring column
          # peeks in. Almost no gap at the top: the Noctalia bar sits there.
          gaps_in = 5;
          gaps_out = {
            top = 5;
            right = 15;
            bottom = 10;
            left = 15;
          };
          border_size = 4;
        };

        scrolling = {
          column_width = 0.5;
          explicit_column_widths = "0.333, 0.5, 0.667";
          fullscreen_on_one_column = true;
          focus_fit_method = 1;
          wrap_focus = false;
          wrap_swapcol = false;
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "0xee1a1a1a";
          };

          blur.enabled = false;
        };

        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
          middle_click_paste = false;
          # If the lock screen (Noctalia) crashes while locked, a new one can take over.
          allow_session_lock_restore = true;
        };

        animations.enabled = true;
      };

    };

    programs.noctalia.settings.theme.templates.builtin_ids = [ "hyprland" ];

    wayland.windowManager.hyprland.extraConfig = ''
      -- Border colours from Noctalia's hyprland template (hypr/noctalia.lua),
      -- which only exists after Noctalia's first render.
      pcall(function()
        require("noctalia").apply_theme()
      end)

      -- Hyprland's default curves and animations.
      hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
      hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
      hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
      hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
      hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

      hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
      hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
      hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
      hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
      hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
      hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
      hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
      hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
      hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
      hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
    '';
  };
}
