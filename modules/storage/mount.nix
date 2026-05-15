{ lib, ... }:
{
  flake.modules.nixos.pc = {
    services.udisks2.enable = true;
  };

  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      term = hmArgs.config.terminal.path;
    in
    {
      # Remember to enable udisks2 as well with nix option services.udisks2.enable = true;
      services.udiskie = {
        enable = true;
        settings = {
          # workaround for
          # https://github.com/nix-community/home-manager/issues/632
          program_options = {
            # replace with your favorite file manager
            file_manager = "${term} -e ${lib.getExe pkgs.yazi}";
          };
        };
      };
    };
}
