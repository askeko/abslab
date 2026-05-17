{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      # TODO: Adopt lua config instead of hyprlang
      wayland.windowManager.hyprland.configType = "hyprlang";
      wayland.windowManager.hyprland.settings = {
        general = {
          gaps_in = 5;
          gaps_out = "8,8,8,8";
          border_size = 3;
          layout = "scrolling";
        };

        animations = {
          enabled = true;

          # Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
          bezier = [
            # NAME,          X0,   Y0,   X1,   Y1
            "easeOutQuint,   0.23, 1,    0.32, 1"
            "easeInOutCubic, 0.65, 0.05, 0.36, 1"
            "linear,         0,    0,    1,    1"
            "almostLinear,   0.5,  0.5,  0.75, 1"
            "quick,          0.15, 0,    0.1,  1"
          ];

          # Default animations, see https://wiki.hypr.land/Configuring/Animations/
          animation = [
            # NAME,         ONOFF, SPEED, CURVE,        [STYLE]
            "global,        1,     10,    default"
            "border,        1,     5.39,  easeOutQuint"
            "windows,       1,     4.79,  easeOutQuint"
            "windowsIn,     1,     4.1,   easeOutQuint, popin 87%"
            "windowsOut,    1,     1.49,  linear,       popin 87%"
            "fadeIn,        1,     1.73,  almostLinear"
            "fadeOut,       1,     1.46,  almostLinear"
            "fade,          1,     3.03,  quick"
            "layers,        1,     3.81,  easeOutQuint"
            "layersIn,      1,     4,     easeOutQuint, fade"
            "layersOut,     1,     1.5,   linear,       fade"
            "fadeLayersIn,  1,     1.79,  almostLinear"
            "fadeLayersOut, 1,     1.39,  almostLinear"
            "workspaces,    1,     1.94,  almostLinear, fade"
            "workspacesIn,  1,     1.21,  almostLinear, fade"
            "workspacesOut, 1,     1.94,  almostLinear, fade"
            "zoomFactor,    1,     7,     quick"
          ];
        };

        decoration = {
          rounding = 5;
          blur = {
            enabled = true;
            size = 10;
          };
          shadow = {
            enabled = true;
          };
        };

        bind =
          let
            hjkl =
              mod: f:
              {
                h = "l";
                j = "d";
                k = "u";
                l = "r";
              }
              |> lib.mapAttrsToList (k: d: "${mod}, ${k}, ${f d}");
          in
          lib.concatLists [
            [
              "SUPER, q, killactive"

              "SUPER, f, fullscreen, 1"
              "SUPER+SHIFT, f, fullscreen, 0"

              "SUPER+SHIFT, space, togglefloating"
            ]

            (hjkl "SUPER" (d: "movefocus, ${d}"))
            (hjkl "SUPER+SHIFT" (d: "movewindow, ${d}"))

            (
              lib.genList (i: i + 1) 9
              |> map (ws: [
                "SUPER, ${toString ws}, workspace, ${toString ws}"
                "SUPER+SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
              ])
              |> lib.concatLists
            )
            [
              "SUPER, 0, workspace, 10"
              "SUPER+SHIFT, 0, movetoworkspace, 10"
            ]
          ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
      };
    };
}
