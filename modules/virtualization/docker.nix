{
  flake.modules.nixos.pc = {

    virtualisation.docker = {
      enable = true; # DNS settings not fixed on eduroam yet
      daemon.settings = {
        default-address-pools = [
          {
            base = "10.200.0.0/16";
            size = 24;
          }
        ];
      };
    };
  };
}
