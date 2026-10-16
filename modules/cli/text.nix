{
  flake.modules.homeManager.base = {
    programs.bat.enable = true;
    home.shellAliases.cat = "bat";
  };
}
