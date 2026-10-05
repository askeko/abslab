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
        # Password first, then touch. With u2f ahead of unix (the default
        # order) hyprlock starts PAM the instant it locks — which on unplug is
        # while the key is absent — so pam_u2f fails before you ever type, and
        # the first password attempt is doomed. Running unix first defers the
        # key check until after the password, by which point it's plugged back in.
        #   unix requisite  → wrong password aborts without asking for a touch
        #   u2f  sufficient → touch completes auth (a prior requisite failure
        #                     can't be overridden), else fall through to deny
        hyprlock = {
          u2fAuth = true;
          rules.auth.unix = {
            control = lib.mkForce "requisite";
            order = config.security.pam.services.hyprlock.rules.auth.u2f.order - 10;
          };
          rules.auth.u2f.control = lib.mkForce "sufficient";
        };
        sudo.u2fAuth = lib.mkDefault false;
        su.u2fAuth = lib.mkDefault false;
        "su-l".u2fAuth = lib.mkDefault false;
        polkit-1.u2fAuth = lib.mkDefault false; # no touch on GUI auth prompts
      };

      # SSH: pubkey auth bypasses the PAM auth stack, so u2f never applies there.
      # Only matters for *password* SSH — a key can't be touched remotely. For
      # "password + touch" over SSH use an ed25519-sk key + AuthenticationMethods
      # instead. No-op until openssh is enabled.
      security.pam.services.sshd.u2fAuth = lib.mkIf config.services.openssh.enable (lib.mkDefault false);

      environment.systemPackages = with pkgs; [
        yubikey-manager # `ykman` — set the FIDO2 PIN, inspect the key
        pam_u2f # `pamu2fcfg` — generate the U2F key mapping file
        libfido2 # `fido2-token` — low-level FIDO2 tooling
      ];

      services.udev.packages = [ pkgs.yubikey-personalization ];

      # Unplug the key and every session locks immediately. Match only the
      # usb_device node: each interface (OTP/FIDO/CCID) fires its own remove
      # event, which spawned several racing hyprlock instances. Match on the
      # kernel's PRODUCT (vid/pid/rev): the usb_id-derived ID_VENDOR_ID/ID_BUS
      # aren't present on the usb_device remove event.
      services.udev.extraRules = ''
        ACTION=="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="1050/*", RUN+="${lib.getExe' pkgs.systemd "loginctl"} lock-sessions"
      '';
    };
}
