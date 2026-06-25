{
  flake.modules.homeManager.gui =
    { pkgs, lib, config, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;
      backlight = pkgs.writeShellApplication {
        name = "waybar-backlight";
        runtimeInputs = [ pkgs.brightnessctl ];
        text = ''
          brightness=$(brightnessctl get)
          max=$(brightnessctl max)
          percent=$(( brightness * 100 / max ))
          if [ "$percent" -le 10 ]; then icon="󱩎"
          elif [ "$percent" -le 20 ]; then icon="󱩏"
          elif [ "$percent" -le 30 ]; then icon="󱩐"
          elif [ "$percent" -le 40 ]; then icon="󱩑"
          elif [ "$percent" -le 50 ]; then icon="󱩒"
          elif [ "$percent" -le 60 ]; then icon="󱩓"
          elif [ "$percent" -le 70 ]; then icon="󱩔"
          elif [ "$percent" -le 80 ]; then icon="󱩕"
          elif [ "$percent" -le 90 ]; then icon="󱩖"
          else icon="󰛨"
          fi
          echo "$icon"
        '';
      };
    in
    {
      programs.waybar = {
        enable = true;
        style = /* css */ ''
          @define-color background ${c.base00};
          @define-color foreground ${c.base05};
          @define-color red        ${c.base08};
          @define-color orange     ${c.base09};
          @define-color yellow     ${c.base0A};
          @define-color green      ${c.base0B};
          @define-color cyan       ${c.base0C};
          @define-color blue       ${c.base0D};
          @define-color magenta    ${c.base0E};

          @keyframes blink {
            to {
              background-color: @red;
            }
          }

          * {
            font-family:
              Symbols Nerd Font,
              FiraCode Nerd Font Mono;
            font-size: 15px;
            min-height: 0;
            margin-top: 0px;
          }

          #custom-temperature,
          #cpu,
          #memory,
          #disk,
          #network,
          #custom-vpn,
          #custom-nix,
          #custom-music,
          #tray,
          #custom-backlight,
          #clock,
          #custom-battery,
          #wireplumber,
          #custom-scrot {
            background-color: @background;
            padding: 0.5rem 0.8rem;
            margin: 8px 0 0 0;
          }

          #waybar {
            background: transparent;
            color: @background;
          }

          #workspaces {
            background-color: @background;
            border-radius: 1rem;
            margin: 8px;
            margin-left: 1rem;
            margin-bottom: 0;
            padding-left: 8px;
            padding-right: 8px;
          }

          #workspaces button {
            color: @foreground;
            border-radius: 1rem;
            padding: 0.4rem;
          }

          #workspaces button.empty {
            color: @foreground;
            border-radius: 1rem;
          }

          #workspaces button.active {
            color: @cyan;
            border-radius: 1rem;
          }

          #workspaces button:hover {
            color: @magenta;
            border-radius: 1rem;
          }

          #workspaces button.urgent {
            color: @red;
            border-radius: 1rem;
            animation-name: blink;
            animation-duration: 1s;
            animation-timing-function: steps(200);
            animation-iteration-count: infinite;
            animation-direction: alternate;
          }

          #custom-temperature {
            color: @yellow;
            border-radius: 1rem 0px 0px 1rem;
            margin-left: 1rem;
          }

          #custom-temperature.critical {
            animation-name: blink;
            animation-duration: 1s;
            animation-timing-function: steps(200);
            animation-iteration-count: infinite;
            animation-direction: alternate;
          }

          #cpu {
            color: @magenta;
          }

          #memory {
            color: @cyan;
          }

          #disk {
            color: @blue;
            border-radius: 0px 1rem 1rem 0px;
            margin-right: 1rem;
          }

          #network {
            color: @magenta;
          }

          #custom-vpn.connected {
            color: @green;
          }

          #custom-vpn.disconnected {
            color: @red;
            opacity: 0.5;
          }

          #custom-nix {
            color: @orange;
            border-radius: 1rem 0px 0px 1rem;
            margin-left: 1rem;
          }

          #clock {
            color: @blue;
            border-radius: 0px 1rem 1rem 0px;
            margin-right: 1rem;
          }

          #custom-battery {
            color: @cyan;
          }

          #custom-battery.critical {
            animation-name: blink;
            animation-duration: 1s;
            animation-timing-function: steps(200);
            animation-iteration-count: infinite;
            animation-direction: alternate;
          }

          #custom-backlight {
            color: @yellow;
          }

          #wireplumber {
            color: @green;
            border-radius: 1rem 0px 0px 1rem;
            margin-left: 1rem;
          }

          #wireplumber.muted {
            color: @background;
            background-color: @red;
          }

          #custom-music {
            color: @cyan;
            border-radius: 1rem;
          }

          #custom-scrot {
            margin-right: 1rem;
            border-radius: 1rem;
            color: @green;
          }

          #tray {
            margin-right: 1rem;
            border-radius: 1rem;
          }
        '';
        settings = {
          mainBar = {
            layer = "top";
            position = "top";

            modules-left = [
              "hyprland/workspaces"
              "custom/temperature"
              "cpu"
              "memory"
              "disk"
            ];
            modules-center = [ "custom/music" ];
            modules-right = [
              "wireplumber"
              "custom/backlight"
              "network"
              "custom/vpn"
              "custom/battery"
              "clock"
              "tray"
            ];

            "hyprland/workspaces" = {
              active-only = false;
              all-outputs = true;
              show-special = true;
              format = "{icon}";
              format-icons = {
                active = "󱄅";
                persistent = "";
                empty = "";
                urgent = "";
                default = "󱄅";
              };
              persistent-workspaces = {
                "*" = [
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                  8
                  9
                  10
                ];
              };
            };

            tray = {
              icon-size = 18;
              spacing = 10;
            };

            "custom/temperature" = {
              format = "{}";
              interval = 5;
              return-type = "json";
              exec = ''
                temp=$(${lib.getExe pkgs.lm_sensors} -j 2>/dev/null | ${lib.getExe pkgs.jq} -r '
                  [.. | objects | to_entries[] | select(.key == "temp1_input")] | first | .value | round
                ')
                if [ -z "$temp" ]; then
                  echo '{"text":"󱃃 ?°", "class":""}'
                  exit 0
                fi
                if [ "$temp" -ge 80 ]; then icon="󰸁"; class="critical"
                elif [ "$temp" -ge 60 ]; then icon="󱩿"; class=""
                else icon="󱃃"; class=""
                fi
                echo "{\"text\":\"''${icon} ''${temp}°\", \"class\":\"''${class}\"}"
              '';
            };

            cpu = {
              format = "󰻠 {usage}%";
            };

            memory = {
              format = "󰍛 {}%";
            };

            network = {
              format-wifi = "󰘊 {signalStrength}%";
              format-ethernet = "󰈀";
              tooltip-format = "󰈀 {ifname} via {gwaddr}";
              format-disconnected = "󰞃 Disconnected";
            };

            "custom/vpn" = {
              return-type = "json";
              interval = 5;
              exec = ''
                iface=$(${lib.getExe' pkgs.iproute2 "ip"} -j -d link show | ${lib.getExe pkgs.jq} -r '[.[] | select(.linkinfo.info_kind == "wireguard")] | .[0].ifname // empty')
                if [ -n "$iface" ]; then
                  echo "{\"text\":\"󰒃 $iface\", \"class\":\"connected\"}"
                else
                  echo "{\"text\":\"󰦝\", \"class\":\"disconnected\"}"
                fi
              '';
            };

            disk = {
              interval = 30;
              format = "󱛟 {used}";
              unit = "GB";
              path = "/";
            };

            "custom/music" = {
              format = " {}";
              escape = true;
              tooltip = false;
              exec = "${lib.getExe pkgs.playerctl} --player=playerctld --follow metadata --format='{{ title }}' 2>/dev/null";
              on-click = "${lib.getExe pkgs.playerctl} play-pause";
              max-length = 40;
            };

            clock = {
              tooltip = false;
              timezone = "Europe/Copenhagen";
              format = "󰥔 {:%H:%M | %d/%m}";
            };

            "custom/battery" = {
              return-type = "json";
              interval = 30;
              exec-if = "ls /sys/class/power_supply/ | grep -q '^BAT'";
              exec = ''
                capacity=$(cat /sys/class/power_supply/BAT0/capacity)
                status=$(cat /sys/class/power_supply/BAT0/status)
                if [ "$status" = "Charging" ]; then icon="󰂄"
                elif [ "$status" = "Full" ]; then icon="󰚥"
                elif [ "$capacity" -le 10 ]; then icon="󰁺"
                elif [ "$capacity" -le 20 ]; then icon="󰁻"
                elif [ "$capacity" -le 30 ]; then icon="󰁼"
                elif [ "$capacity" -le 40 ]; then icon="󰁽"
                elif [ "$capacity" -le 50 ]; then icon="󰁾"
                elif [ "$capacity" -le 60 ]; then icon="󰁿"
                elif [ "$capacity" -le 70 ]; then icon="󰂀"
                elif [ "$capacity" -le 80 ]; then icon="󰂁"
                elif [ "$capacity" -le 90 ]; then icon="󰂂"
                else icon="󱐋"
                fi
                class=""
                if [ "$status" = "Discharging" ] && [ "$capacity" -le 15 ]; then class="critical"; fi
                echo "{\"text\":\"''${icon} ''${capacity}%\", \"class\":\"''${class}\"}"
              '';
            };

            "custom/backlight" = {
              interval = 2;
              exec-if = "ls /sys/class/backlight/ 2>/dev/null | grep -q .";
              exec = lib.getExe backlight;
            };

            wireplumber = {
              tooltip = false;
              format = "{icon} {volume}%";
              format-muted = "";
              max-volume = 120;
              format-icons = [
                ""
                ""
                ""
              ];
            };

            "custom/scrot" = {
              tooltip = false;
              on-click = "";
              format = "";
            };
          };
        };
      };

      wayland.windowManager.hyprland.settings.exec-once = [ "waybar" ];
    };
}
