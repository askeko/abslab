{
  flake.modules.nixos.pc = {
    programs.nix-ld = {
      enable = true;
    };
  };
}
