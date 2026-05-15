{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, lib, ... }:
    {
      wayland.windowManager.hyprland.settings.bind =
        let
          rofi-pwr-menu = pkgs.writeShellApplication {
            name = "rofi-pwr-menu";
            runtimeInputs = [
              hmArgs.config.programs.rofi.package
              hmArgs.config.programs.hyprlock.package
              pkgs.hyprland
            ];
            text = ''
              case "$(printf "󰌾  Lock\n󰗽  Logout\n󰜉  Reboot\n󰐥  Shutdown" | rofi -dmenu -p 'Action: ')" in
              '󰌾  Lock') hyprlock ;;
              '󰗽  Logout') hyprctl dispatch exit ;;
              '󰜉  Reboot') systemctl reboot -i ;;
              '󰐥  Shutdown') systemctl poweroff -i ;;
              *) exit 1 ;;
              esac
            '';
          };
        in
        [ "SUPER+SHIFT, q, exec, ${lib.getExe rofi-pwr-menu}" ];
    };
}
