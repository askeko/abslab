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
            color = lib.mkDefault "on_surface";
            icon_color = lib.mkDefault "on_surface";
            hover_highlight = lib.mkDefault true;
            capsule = lib.mkDefault false;

            start = lib.mkDefault [
              "audio_vis"
              "workspaces"
              "temp"
              "cpu"
              "ram"
              "disk"
            ];
            center = lib.mkDefault [ "clock" ];
            end = lib.mkDefault [
              "media"
              "volume"
              "brightness"
              "bluetooth"
              "privacy"
              "network"
              "vpn"
              "battery"
              "tray"
              "notifications"
              "session"
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
            style = lib.mkDefault "focus_hint";
            show_labels = lib.mkDefault true;
            show_icons = lib.mkDefault false;
            label_source = lib.mkDefault "id";
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
            visualization = lib.mkDefault "graph";
            show_value = lib.mkDefault false;
          };

          ram = {
            type = lib.mkDefault "sysmon";
            stat = lib.mkDefault "ram_used";
            visualization = lib.mkDefault "graph";
            show_value = lib.mkDefault false;
          };

          disk = {
            type = lib.mkDefault "sysmon";
            stat = lib.mkDefault "disk_used_pct";
            path = lib.mkDefault "/";
            visualization = lib.mkDefault "graph";
            show_value = lib.mkDefault false;
          };

          volume = {
            show_label = lib.mkDefault true;
            actions.right = lib.mkDefault "exec ${lib.getExe pkgs.pwvucontrol}";
          };

          privacy = {
            type = lib.mkDefault "privacy";
            hide_inactive = lib.mkDefault false;
            icon_spacing = lib.mkDefault 6;
            active_color = lib.mkDefault "primary";
            inactive_color = lib.mkDefault "outline";
          };
        };
      };
    };
}
