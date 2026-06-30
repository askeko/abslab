{ ... }:
{
  flake.modules.nixos.pc =
    { pkgs, lib, config, ... }:
    {
      # ---- YubiKey as a real second factor: every login + unlock ------------
      # `enable = true` flips the per-service `u2fAuth` default to true for EVERY
      # PAM auth service, so the key is required by default; we then opt OUT of
      # the services that aren't "logins" (sudo/su/polkit) or can't reach a
      # remote key (sshd). Net result: password + key at hyprlock (unlock), TTY
      # `login`, AND the tuigreet greeter (post-logout, via the `greetd` PAM
      # service). Boot stays promptless: greetd's `initial_session` autologin is
      # unauthenticated, so it never runs this auth stack.
      #
      # `control = "required"` => password AND key are both required (not "or").
      #
      # Per-machine: u2f creds are host-scoped (origin pam://<host>) and
      # ~/.config/Yubico/u2f_keys lives in each machine's own /home — so every
      # host importing `pc` (lazarus + halflight) must enrol its keys with
      # `pamu2fcfg` BEFORE it rebuilds, or login/greeter/hyprlock will demand a
      # key with no mapping.
      security.pam.u2f = {
        enable = true;
        control = "required";
        settings.cue = true; # show a "touch your key" prompt
      };

      security.pam.services = {
        # `login` and `greetd` (greeter) inherit the global `true` — both gated.
        hyprlock.u2fAuth = true; # merges with the empty service in screenlock.nix
        sudo.u2fAuth = lib.mkDefault false; # privilege op, not a login
        su.u2fAuth = lib.mkDefault false; # kept password-only (your call)
        polkit-1.u2fAuth = lib.mkDefault false; # no touch on GUI auth prompts
      };

      # SSH: pubkey auth bypasses the PAM auth stack, so u2f never applies there.
      # Only matters for *password* SSH — a key can't be touched remotely. For
      # "password + touch" over SSH use an ed25519-sk key + AuthenticationMethods
      # instead. No-op until openssh is enabled.
      security.pam.services.sshd.u2fAuth = lib.mkIf config.services.openssh.enable (lib.mkDefault false);

      # ---- Tooling + device access -----------------------------------------
      environment.systemPackages = with pkgs; [
        yubikey-manager # `ykman` — set the FIDO2 PIN, inspect the key
        pam_u2f # `pamu2fcfg` — generate the U2F key mapping file
        libfido2 # `fido2-token` — low-level FIDO2 tooling
      ];

      services.udev.packages = [ pkgs.yubikey-personalization ];

      # ---- Auto-lock on removal --------------------------------------------
      # Unplug the key and every session locks immediately.
      services.udev.extraRules = ''
        ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="1050", ENV{ID_VENDOR}=="Yubico", RUN+="${lib.getExe' pkgs.systemd "loginctl"} lock-sessions"
      '';
    };
}
