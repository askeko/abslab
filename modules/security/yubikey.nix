{ ... }:
{
  flake.modules.nixos.pc =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      security.pam.u2f = {
        enable = true;
        control = "required";
        settings.cue = true; # show a "touch your key" prompt
      };

      security.pam.services = {
        # `login` covers TTY logins and Noctalia's lock screen, which
        # authenticates against it. Password first, then touch, so the key is
        # only asked for once it's plugged back in after an unplug lock.
        #   unix requisite  → wrong password aborts without asking for a touch
        #   u2f  sufficient → touch completes auth (a prior requisite failure
        #                     can't be overridden), else fall through to deny
        login = {
          u2fAuth = true;
          rules.auth.unix = {
            control = lib.mkForce "requisite";
            order = config.security.pam.services.login.rules.auth.u2f.order - 10;
          };
          rules.auth.u2f.control = lib.mkForce "sufficient";
        };
        sudo.u2fAuth = lib.mkDefault false;
        su.u2fAuth = lib.mkDefault false;
        "su-l".u2fAuth = lib.mkDefault false;
        polkit-1.u2fAuth = lib.mkDefault false; # no touch on GUI auth prompts
      };

      environment.systemPackages = with pkgs; [
        yubikey-manager # `ykman` — set the FIDO2 PIN, inspect the key
        pam_u2f # `pamu2fcfg` — generate the U2F key mapping file
        libfido2 # `fido2-token` — low-level FIDO2 tooling
      ];

      services.udev.packages = [ pkgs.yubikey-personalization ];

      # Unplug the key and every session locks immediately. Match only the
      # usb_device node: each interface (OTP/FIDO/CCID) fires its own remove
      # event, which would send several lock requests. Match on the
      # kernel's PRODUCT (vid/pid/rev): the usb_id-derived ID_VENDOR_ID/ID_BUS
      # aren't present on the usb_device remove event.
      services.udev.extraRules = ''
        ACTION=="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="1050/*", RUN+="${lib.getExe' pkgs.systemd "loginctl"} lock-sessions"
      '';
    };
}
