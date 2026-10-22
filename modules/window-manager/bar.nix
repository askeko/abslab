{ config, lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      programs.noctalia.settings = {
        bar = {
          order = lib.mkDefault [ "top" ];

          # Floats off the top and sides, rounded all round.
          top = {
            position = lib.mkDefault "top";
            thickness = lib.mkDefault 36;
            reserve_space = lib.mkDefault true;
            layer = lib.mkDefault "top";

            background_opacity = lib.mkDefault 1.0;
            compositor_blur = lib.mkDefault false;
            border = lib.mkDefault "outline";
            border_width = lib.mkDefault 1;
            shadow = lib.mkDefault true;
            radius = lib.mkDefault 12;
            concave_edge_corners = lib.mkDefault false;
            margin_edge = lib.mkDefault 10;
            margin_ends = lib.mkDefault 20;
            padding = lib.mkDefault 12;
            widget_spacing = lib.mkDefault 10;

            scale = lib.mkDefault 1.0;
            font_weight = lib.mkDefault 500;
            font_family = lib.mkDefault config.flake.meta.fonts.monospace.name;
            hover_highlight = lib.mkDefault true;
            capsule = lib.mkDefault false;

            start = lib.mkDefault [
              "group:power"
              "workspaces"
              "group:system"
            ];
            center = lib.mkDefault [ "group:media" ];
            end = lib.mkDefault [
              "group:audio"
              "group:connectivity"
              "group:time"
              "group:tray"
            ];

            # Widgets sit on neutral capsules, grouped by category.
            capsule_group =
              let
                group = id: members: {
                  inherit id members;
                  fill = "surface_variant";
                };
              in
              lib.mkDefault [
                (group "power" [
                  "session"
                  "battery"
                ])
                (group "system" [
                  "temp"
                  "cpu"
                  "ram"
                  "disk"
                ])
                (group "media" [
                  "media"
                  "audio_vis"
                ])
                (group "audio" [
                  "volume"
                  "camera"
                  "privacy"
                ])
                (group "connectivity" [
                  "network"
                  "vpn"
                  "bluetooth"
                ])
                (group "time" [
                  "notifications"
                  "clock"
                ])
                (group "tray" [ "tray" ])
              ];
          };
        };

        widget = {
          audio_vis = {
            type = lib.mkDefault "audio_visualizer";
            width = lib.mkDefault 140;
            bands = lib.mkDefault 28;
            mirrored = lib.mkDefault true;
            centered = lib.mkDefault true;
            show_when_idle = lib.mkDefault true;
            color_1 = lib.mkDefault "primary";
            color_2 = lib.mkDefault "primary";
          };

          workspaces = {
            # Just the NixOS glyph (from the workspace rules), no pills: the
            # label itself takes the state colour.
            style = lib.mkDefault "minimal";
            show_labels = lib.mkDefault true;
            label_source = lib.mkDefault "name";
            # Scale shrinks the fixed gaps between icons (12 px → 6 px). The
            # non-Mono symbols font draws the icon 1.6 × larger than the Mono
            # bar font, so it stays big within the font scale's 2.5 cap.
            scale = lib.mkDefault 0.5;
            font_scale = lib.mkDefault 2.1;
            font_family = lib.mkDefault "Symbols Nerd Font";
            focused_color = lib.mkDefault "primary";
            occupied_color = lib.mkDefault "secondary";
            empty_color = lib.mkDefault "on_surface";
          };

          clock.format = lib.mkDefault "%b %d  %H:%M";

          media = {
            max_length = lib.mkDefault 430;
            rotate_album_art = lib.mkDefault true;
            title_scroll = lib.mkDefault "none";
          };

          temp = {
            type = lib.mkDefault "sysmon";
            stat = lib.mkDefault "cpu_temp";
          };

          cpu = {
            type = lib.mkDefault "sysmon";
            stat = lib.mkDefault "cpu_usage";
            visualization = lib.mkDefault "none";
            show_value = lib.mkDefault true;
          };

          ram = {
            type = lib.mkDefault "sysmon";
            stat = lib.mkDefault "ram_pct";
            visualization = lib.mkDefault "none";
            show_value = lib.mkDefault true;
          };

          disk = {
            type = lib.mkDefault "sysmon";
            stat = lib.mkDefault "disk_used_pct";
            path = lib.mkDefault "/";
            visualization = lib.mkDefault "none";
            show_value = lib.mkDefault true;
          };

          session.icon_color = lib.mkDefault "error";

          volume = {
            show_label = lib.mkDefault true;
            actions.right = lib.mkDefault "exec ${lib.getExe pkgs.pwvucontrol}";
          };

          # Only while something is captured.
          privacy = {
            type = lib.mkDefault "privacy";
            hide_inactive = lib.mkDefault true;
            icon_spacing = lib.mkDefault 6;
            active_color = lib.mkDefault "primary";
            inactive_color = lib.mkDefault "outline";
          };
        };
      };
    };
}
