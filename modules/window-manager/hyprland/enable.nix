{ lib, ... }:
{
  # Hyprland with the scrolling layout, started by uwsm as a systemd session
  # (graphical-session.target). Session services (Noctalia, udiskie, …) are
  # systemd user units; nothing is started from the compositor config.
  flake.modules.nixos.pc =
    { config, pkgs, ... }:
    {
      programs.hyprland = {
        enable = lib.mkDefault true;
        withUWSM = lib.mkDefault true;
      };

      # File pickers (the Hyprland portal has none).
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # Logins (greetd's PAM includes `login`) unlock the `login` keyring with
      # the password. Its auth step has to see the password before the YubiKey
      # touch, whose `sufficient` success ends auth (security/yubikey.nix).
      services.gnome.gnome-keyring.enable = lib.mkDefault true;
      security.pam.services.login.rules.auth.gnome_keyring.order =
        config.security.pam.services.login.rules.auth.u2f.order - 5;
    };

  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;
        # Package, portal and session come from the NixOS module; uwsm
        # manages graphical-session.target.
        package = null;
        portalPackage = null;
        systemd.enable = false;
        configType = "lua";

        # Helpers for the binds that feature modules add to extraConfig. Every
        # bind has a description; Mod+Shift+/ lists them (hyprland/keybinds.nix).
        settings = {
          mod._var = "SUPER";
          bind._var = mkLuaInline ''
            function(keys, action, desc, opts)
              local o = { description = desc }
              for k, v in pairs(opts or {}) do
                o[k] = v
              end
              hl.bind(keys, action, o)
            end'';
          # Apps and menus run in their own systemd scope (uwsm), not inside
          # Hyprland's; quick one-shot commands run directly.
          app._var = mkLuaInline ''
            function(c)
              return hl.dsp.exec_cmd("${lib.getExe' pkgs.uwsm "uwsm-app"} -- " .. c)
            end'';
          cmd._var = mkLuaInline "hl.dsp.exec_cmd";
        };
      };

      # The session environment (uwsm) gets the same variables as login shells.
      xdg.configFile."uwsm/env".text = ''
        . "${hmArgs.config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      '';
    };
}
