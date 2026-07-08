{ lib, ... }:
{
  flake.modules.homeManager.gui = {
    programs.niri.settings = {
      # Border colors and cursor come from niri-flake's stylix target
      # (injected via home-manager.sharedModules in enable.nix); only
      # geometry is set here.
      layout = {
        #gaps = 8;
        #border.width = 3;
        #default-column-width.proportion = 0.5;
        #preset-column-widths = [
        #  { proportion = 1.0 / 3.0; }
        #  { proportion = 0.5; }
        #  { proportion = 2.0 / 3.0; }
        #];

        #empty-workspace-above-first = true;

        ## fog of war
        #focus-ring = {
        #  enable = false;
        #  width = 10000;
        #  active.color = "#00000055";
        #};
        gaps = 16;
        struts.left = 32;
        struts.right = 32;

        always-center-single-column = true;

        empty-workspace-above-first = true;

        # fog of war
        focus-ring = {
          enable = false;
          width = 10000;
          active.color = "#00000055";
        };

        border = {
          enable = true;
          width = 4;
        };

        # border.active.gradient = {
        #   from = "red";
        #   to = "blue";
        #   in' = "oklch shorter hue";
        # };

        shadow.enable = true;

        # default-column-display = "tabbed";

        tab-indicator = {
          position = "top";
          gaps-between-tabs = 10;

          # hide-when-single-tab = true;
          # place-within-column = true;

          # active.color = "red";
        };
      };

      prefer-no-csd = true;

      # TODO: Need to change colors to stylix. Haven't tested if this works yet
      window-rules = [
        # Border color for screencasted windows
        {
          matches = [
            { is-window-cast-target = true; }
          ];

          focus-ring = {
            active.color = "#f38ba8";
            inactive.color = "#7d0d2d";
          };

          border.inactive.color = "#7d0d2d";

          shadow = {
            color = "#7d0d2d70";
          };

          tab-indicator = {
            active.color = "#f38ba8";
            inactive.color = "#7d0d2d";
          };
        }

        {
          geometry-corner-radius =
            let
              r = 8.0;
            in
            {
              top-left = r;
              top-right = r;
              bottom-left = r;
              bottom-right = r;
            };

          clip-to-geometry = true;
        }
      ];

      # Mouse move (Mod+drag) and resize (Mod+right-drag) are built into Niri
      binds =
        let
          hjkl =
            mods: f:
            {
              H = "left";
              J = "down";
              K = "up";
              L = "right";
            }
            |> lib.mapAttrs' (key: dir: lib.nameValuePair "${mods}+${key}" { action.${f dir} = [ ]; });
          workspaces =
            lib.genList (i: i + 1) 10
            |> map (ws: {
              # Workspace indices are per-monitor in niri's dynamic model.
              "Mod+${toString (lib.mod ws 10)}".action.focus-workspace = ws;
              "Mod+Shift+${toString (lib.mod ws 10)}".action.move-column-to-workspace = ws;
            })
            |> lib.mergeAttrsList;
        in
        lib.mergeAttrsList [
          {
            "Mod+Q".action.close-window = [ ];

            "Mod+F".action.maximize-column = [ ];
            "Mod+Shift+F".action.fullscreen-window = [ ];

            "Mod+Shift+Space".action.toggle-window-floating = [ ];

            "Mod+Comma".action.consume-window-into-column = [ ];
            "Mod+Period".action.expel-window-from-column = [ ];
            "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
            "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

            "Mod+R".action.switch-preset-column-width = [ ];
            "Mod+Ctrl+R".action.switch-preset-window-height = [ ];
            "Mod+Minus".action.set-column-width = "-10%";
            "Mod+Plus".action.set-column-width = "+10%";
            "Mod+C".action.center-column = [ ];

            "Mod+O".action.toggle-overview = [ ];
            "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

            "Mod+Ctrl+J".action.focus-workspace-down = [ ];
            "Mod+Ctrl+K".action.focus-workspace-up = [ ];
            "Mod+Ctrl+Shift+J".action.move-column-to-workspace-down = [ ];
            "Mod+Ctrl+Shift+K".action.move-column-to-workspace-up = [ ];
            "Mod+WheelScrollDown" = {
              action.focus-workspace-down = [ ];
              cooldown-ms = 150;
            };
            "Mod+WheelScrollUp" = {
              action.focus-workspace-up = [ ];
              cooldown-ms = 150;
            };

            "Mod+Ctrl+H".action.focus-monitor-left = [ ];
            "Mod+Ctrl+L".action.focus-monitor-right = [ ];
            "Mod+Ctrl+Shift+H".action.move-column-to-monitor-left = [ ];
            "Mod+Ctrl+Shift+L".action.move-column-to-monitor-right = [ ];
          }

          # Vim navigation: left/right walk columns, down/up walk windows in
          # the column and fall through to the next workspace at the edge.
          (hjkl "Mod" (
            dir:
            if dir == "left" || dir == "right" then
              "focus-column-${dir}"
            else
              "focus-window-or-workspace-${dir}"
          ))
          (hjkl "Mod+Shift" (
            dir:
            if dir == "left" || dir == "right" then
              "move-column-${dir}"
            else
              "move-window-${dir}-or-to-workspace-${dir}"
          ))

          workspaces
        ];
    };
  };
}
