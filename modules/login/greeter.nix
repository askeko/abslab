{ config, lib, ... }:
let
  owner = config.flake.meta.owner.username;
in
{
  flake.modules = {
    # Noctalia Greeter on greetd, with absentia and the uwsm Hyprland session
    # preselected, at boot too: no autologin, since the password is what unlocks
    # the keyring. greetd's PAM includes `login`, so it asks for the password,
    # then a YubiKey touch (security/yubikey.nix).
    nixos.pc =
      nixosArgs@{ pkgs, ... }:
      {
        services.displayManager.noctalia-greeter = {
          enable = lib.mkDefault true;
          # Noctalia's appearance-only sync to the greeter runs without a prompt.
          passwordlessSyncUsers = [ owner ];
          # The session's Rosé Pine cursor (style/cursor.nix); the sync doesn't
          # carry the cursor.
          cursorTheme = {
            package = lib.mkDefault pkgs.rose-pine-cursor;
            name = lib.mkDefault "BreezeX-RosePine-Linux";
          };
          settings = {
            session.default = lib.mkDefault "Hyprland (uwsm-managed)";
            user.default = lib.mkDefault owner;
            # Same keymap as the session, so the password types the same.
            keyboard = with nixosArgs.config.services.xserver.xkb; {
              layout = lib.mkDefault layout;
              options = lib.mkDefault options;
            };
          };
        };

        # No avatar in the greeter. Plain priority: the greeter module enables it
        # with mkDefault.
        services.accounts-daemon.enable = false;

        # A clean handoff from the greeter to Hyprland, both on VT1: `uwsm start`
        # logs to the journal instead of painting the VT (pam_env gives greetd's
        # session this variable; 2 also drops warnings, errors still show), and
        # the console cursor stays hidden in the gap between the two compositors.
        environment.sessionVariables.UWSM_SILENT_START = lib.mkDefault "2";
        boot.kernelParams = [ "vt.global_cursor_default=0" ];
      };

    # The greeter's synced appearance survives the root wipe.
    nixos.impermanence.environment.persistence."/persist".directories = [
      {
        directory = "/var/lib/noctalia-greeter";
        user = "greeter";
        group = "greeter";
        mode = "0750";
      }
    ];

    # Wallpaper, palette, light/dark, font and monitor layout follow Noctalia.
    homeManager.gui.programs.noctalia.settings.shell.greeter_sync.auto_sync = lib.mkDefault true;
  };
}
