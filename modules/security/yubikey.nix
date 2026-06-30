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
        hyprlock.u2fAuth = true;
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

      # Unplug the key and every session locks immediately.
      services.udev.extraRules = ''
        ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="1050", ENV{ID_VENDOR}=="Yubico", RUN+="${lib.getExe' pkgs.systemd "loginctl"} lock-sessions"
      '';
    };
}
