{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, lib, ... }:
    let
      rofi-pwr-menu = pkgs.writeShellApplication {
        name = "rofi-pwr-menu";
        runtimeInputs = [
          hmArgs.config.programs.rofi.package
          hmArgs.config.programs.hyprlock.package
          hmArgs.config.programs.niri.package
        ];
        text = ''
          case "$(printf "󰌾  Lock\n󰗽  Logout\n󰜉  Reboot\n󰐥  Shutdown" | rofi -dmenu -p 'Action: ')" in
          '󰌾  Lock') hyprlock ;;
          '󰗽  Logout') niri msg action quit --skip-confirmation ;;
          '󰜉  Reboot') systemctl reboot -i ;;
          '󰐥  Shutdown') systemctl poweroff -i ;;
          *) exit 1 ;;
          esac
        '';
      };
    in
    {
      programs.niri.settings.binds."Mod+Shift+Q".action.spawn = lib.getExe rofi-pwr-menu;
    };
}
