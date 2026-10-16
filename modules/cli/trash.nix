{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.trash-cli ];

      home.shellAliases = {
        t = "trash-put";
        te = "trash-empty";
        tl = "trash-list";
        tre = "trash-restore";
        trm = "trash-rm";
      };
    };
}
