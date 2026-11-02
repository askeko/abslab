{
  # World of Warcraft through Battle.net in Lutris (its Battle.net install
  # script sets up the Wine prefix), with addons managed by WowUp-CF: point it
  # at `drive_c/Program Files (x86)/World of Warcraft/_retail_` in the prefix.
  # The prefix lives under /home, which survives the impermanence wipe.
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.wowup-cf ];

      nixpkgs.config.allowUnfreePackages = [ "wowup-cf" ];
    };

  flake.modules.homeManager.gaming =
    {
      lib,
      pkgs,
      osConfig ? null,
      ...
    }:
    {
      programs.lutris = {
        enable = true;
        # GE-Proton through umu, the runner to pick for Battle.net
        protonPackages = [ pkgs.proton-ge-bin ];
        defaultWinePackage = lib.mkDefault pkgs.proton-ge-bin;
        # The system's Steam, so Lutris doesn't start a second instance
        steamPackage = lib.mkIf (osConfig != null) (lib.mkDefault osConfig.programs.steam.package);
      };
    };
}
