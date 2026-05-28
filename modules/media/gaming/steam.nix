{
  flake.modules.nixos.pc = {

    programs.steam = {
      enable = true;
      # Fix gamescope inside steam
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
    };

    nixpkgs.config.allowUnfreePackages = [
      "steam"
      "steam-unwrapped"
    ];
  };
}
