{ inputs, lib, ... }:
{
  # niri-flake's NixOS module brings the session file (via
  # services.displayManager.sessionPackages), portals (gnome + niri's own
  # portal config), polkit agent, gnome-keyring, and injects its Home Manager
  # settings module into every user via home-manager.sharedModules — including
  # the stylix target (border colors + cursor follow the active scheme).
  # The standalone HM checks don't go through this module; they import the HM
  # module directly in modules/home-manager/checks.nix.
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      programs.niri.enable = lib.mkDefault true;
      # nixpkgs niri over niri-flake's own build — niri-flake's default pins
      # its niri-stable (older), and its binary cache only serves those builds.
      programs.niri.package = lib.mkDefault pkgs.niri;
      niri-flake.cache.enable = lib.mkDefault false;

    };

  # niri-session hops through a login shell (SHLVL=1) and then runs a blanket
  # `systemctl --user import-environment`, so SHLVL leaks into the user
  # manager's activation environment and every terminal's shell reports
  # itself as nested. systemd's UnsetEnvironment= can't catch this — runtime
  # import-environment wins over that filter — so have niri itself unset the
  # variable for everything it spawns (null = unset in niri's environment
  # block).
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      programs.niri.settings.environment.SHLVL = lib.mkDefault null;

      # niri spawns xwayland-satellite on demand and sets DISPLAY for its
      # clients, but only if it can find the binary. niri-flake only fills in
      # the path for its own niri builds — with pkgs.niri it stays null and
      # X11 apps (Discord, etc.) die with "Missing X server or $DISPLAY".
      programs.niri.settings.xwayland-satellite.path = lib.mkDefault (
        lib.getExe pkgs.xwayland-satellite
      );
    };
}
