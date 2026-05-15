{
  flake.modules.homeManager.base = {
    programs.git.settings.rebase.instructionFormat = "%d %s";
  };
}
