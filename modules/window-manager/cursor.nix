{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.pointerCursor = {
        package = pkgs.rose-pine-cursor;
        name = "BreezeX-RosePine-Linux";
        size = 32;
      };
    };
}
