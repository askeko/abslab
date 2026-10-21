{ lib, ... }:
{
  # App launcher and run menu, both in Noctalia's launcher.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      # Run menu (/run): every command on PATH, or whatever is typed. Commands
      # get their own systemd scope, like apps from the launcher.
      programs.noctalia.settings.shell.launcher.dmenu.entry.run = {
        label = lib.mkDefault "Run";
        prefix = lib.mkDefault "run";
        glyph = lib.mkDefault "terminal";
        freeform = lib.mkDefault true;
        command = lib.mkDefault ''IFS=:; for d in $PATH; do [ -d "$d" ] && ls "$d"; done | sort -u'';
        exec = lib.mkDefault "${lib.getExe' pkgs.uwsm "uwsm-app"} -- {selection}";
      };

      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + D", cmd(ipc .. "panel-toggle launcher"), "App launcher")
        bind(mod .. " + SHIFT + D", cmd(ipc .. "panel-toggle launcher /run"), "Run command")
      '';
    };
}
