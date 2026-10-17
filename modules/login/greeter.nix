{ config, lib, ... }:
let
  owner = config.flake.meta.owner.username;
in
{
  # Noctalia Greeter on greetd, with absentia and the uwsm Hyprland session
  # preselected. greetd's PAM includes `login`, so it asks for the password,
  # then a YubiKey touch (security/yubikey.nix).
  flake.modules.nixos.pc = nixosArgs: {
    services.displayManager.noctalia-greeter = {
      enable = lib.mkDefault true;
      # Noctalia's appearance-only sync to the greeter runs without a prompt.
      passwordlessSyncUsers = [ owner ];
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
  };

  # Wallpaper, palette, light/dark, font and monitor layout follow Noctalia.
  flake.modules.homeManager.gui.programs.noctalia.settings.shell.greeter_sync.auto_sync =
    lib.mkDefault true;
}
