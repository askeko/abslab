{ lib, ... }:
{
  # State-coloured bar indicators from our own Noctalia plugin (plugins/status),
  # after Waybar's custom modules: a check script prints the state as JSON and
  # runs again on each event of a watch command. Classes map to the theme's
  # green/yellow/red, which a user template keeps in sync with theme switches.
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      noctalia = lib.getExe hmArgs.config.programs.noctalia.package;
      script =
        name: runtimeInputs: text:
        lib.getExe (
          pkgs.writeShellApplication {
            name = "status-${name}";
            runtimeInputs = runtimeInputs ++ [
              pkgs.coreutils
              pkgs.jq
            ];
            inherit text;
          }
        );
    in
    {
      programs.noctalia.settings = {
        plugins = {
          enabled = [ "absentia/status" ];
          # Read-only from the store; the git sources stay unused.
          source = [
            {
              name = "abslab";
              kind = "path";
              location = "${./plugins}";
              enabled = true;
            }
          ];
          auto_update = lib.mkDefault "none";
        };

        theme.templates.user.status_colors = {
          input_path = lib.mkDefault "${./status-colors.json}";
          output_path = lib.mkDefault "$XDG_CACHE_HOME/noctalia/status-colors.json";
          post_hook = lib.mkDefault "${noctalia} msg plugin absentia/status:exec all palette";
        };

        widget = {
          # Green from 70 %, yellow above 20 %, red below; it blinks while
          # discharging. Hidden without a battery.
          battery = {
            type = lib.mkDefault "absentia/status:exec";
            exec = lib.mkDefault (
              script "battery" [ ] ''
                shopt -s nullglob
                bats=(/sys/class/power_supply/BAT*)
                (( ''${#bats[@]} )) || exit 0
                capacity=$(<"''${bats[0]}/capacity")
                status=$(<"''${bats[0]}/status")

                if (( capacity >= 70 )); then class=good
                elif (( capacity > 20 )); then class=warning
                elif [[ $status == Discharging ]]; then class=critical
                else class=low
                fi

                case $status in
                  Charging) glyph=battery-charging ;;
                  Discharging)
                    level=$(( (capacity + 12) / 25 ))
                    glyph=battery
                    (( level )) && glyph=battery-$level
                    ;;
                  *) glyph=plug-connected ;;
                esac

                jq -nc --arg glyph "$glyph" --arg class "$class" --arg status "$status" --argjson capacity "$capacity" \
                  '{ glyph: $glyph, text: "\($capacity)%", class: $class, tooltip: "\($status), \($capacity) %" }'
              ''
            );
            # Charge changes show within a minute; plugging in at once.
            watch = lib.mkDefault "${lib.getExe' pkgs.systemd "udevadm"} monitor --udev --subsystem-match=power_supply";
            interval = lib.mkDefault 60;
            colors = {
              good = lib.mkDefault "green";
              warning = lib.mkDefault "yellow";
              low = lib.mkDefault "red";
              critical = lib.mkDefault "red";
            };
            blink = lib.mkDefault [ "critical" ];
            actions.left = lib.mkDefault "panel-toggle control-center power";
          };

          # Green with the connection's name, red when offline.
          network = {
            type = lib.mkDefault "absentia/status:exec";
            exec = lib.mkDefault (
              script "network" [ pkgs.networkmanager ] ''
                while IFS=: read -r type state name; do
                  case $type:$state in
                    wifi:connected) glyph=wifi kind=Wi-Fi ;;
                    ethernet:connected) glyph=ethernet kind=Wired ;;
                    *) continue ;;
                  esac
                  jq -nc --arg glyph "$glyph" --arg kind "$kind" --arg name "''${name//\\:/:}" \
                    '{ glyph: $glyph, text: $name, class: "up", tooltip: "\($kind): \($name)" }'
                  exit
                done < <(nmcli -t -f TYPE,STATE,CONNECTION device)
                jq -nc '{ glyph: "wifi-off", class: "down", tooltip: "Offline" }'
              ''
            );
            watch = lib.mkDefault "${lib.getExe' pkgs.networkmanager "nmcli"} monitor";
            colors = {
              up = lib.mkDefault "green";
              down = lib.mkDefault "red";
            };
            actions = {
              left = lib.mkDefault "panel-toggle control-center network";
              right = lib.mkDefault "network-toggle";
            };
          };

          # Green while the adapter is on, greyed out when off. Hidden without one.
          bluetooth = {
            type = lib.mkDefault "absentia/status:exec";
            exec = lib.mkDefault (
              script "bluetooth" [ pkgs.bluez ] ''
                show=$(timeout 5 bluetoothctl show 2>/dev/null) || exit 0
                [[ $show == Controller* ]] || exit 0
                if [[ $show != *"Powered: yes"* ]]; then
                  jq -nc '{ glyph: "bluetooth-off", class: "off", tooltip: "Bluetooth off" }'
                  exit
                fi
                bluetoothctl devices Connected | cut -d' ' -f3- | jq -Rsc 'split("\n") | map(select(. != "")) |
                  if . == [] then { glyph: "bluetooth", class: "on", tooltip: "Bluetooth on" }
                  else { glyph: "bluetooth-connected", class: "on", tooltip: "Connected: \(join(", "))" } end'
              ''
            );
            watch = lib.mkDefault "${lib.getExe' pkgs.glib "gdbus"} monitor --system --dest org.bluez";
            colors = {
              on = lib.mkDefault "green";
              off = lib.mkDefault "outline";
            };
            actions = {
              left = lib.mkDefault "panel-toggle control-center bluetooth";
              right = lib.mkDefault "bluetooth-toggle";
            };
          };

          # Shown while an app opens a camera device directly, skipping PipeWire,
          # which the privacy widget can't see. PipeWire's own captures (held
          # by its daemons) are left to the privacy widget, so none show twice.
          camera = {
            type = lib.mkDefault "absentia/status:exec";
            exec = lib.mkDefault (
              script "camera" [ pkgs.findutils ] ''
                # Other users' processes and ones that exit mid-scan are skipped.
                { find /proc/[0-9]*/fd -lname '/dev/video*' -printf '%h/../comm\n' 2>/dev/null || true; } |
                  { xargs -r cat 2>/dev/null || true; } | sort -u |
                  jq -Rsc 'split("\n") - ["", "pipewire", "wireplumber"] |
                  if . == [] then empty else { glyph: "camera", class: "on", tooltip: "Camera in use: \(join(", "))" } end'
              ''
            );
            # Opens and closes of the camera nodes. A camera coming or going
            # ends the watch, so it restarts on the new set of nodes.
            watch = lib.mkDefault (
              script "camera-watch" [ pkgs.inotify-tools ] ''
                shopt -s nullglob
                nodes=(/dev/video*)
                trap 'kill $(jobs -p) 2>/dev/null || true' EXIT
                if (( ''${#nodes[@]} )); then
                  inotifywait -m -q -e open,close "''${nodes[@]}" &
                fi
                inotifywait -q -e create,delete --include 'video[0-9]+$' /dev
              ''
            );
            # Matches the privacy widget.
            colors.on = lib.mkDefault "primary";
          };
        };
      };
    };
}
