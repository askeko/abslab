{
  flake.modules.homeManager.base.programs = {
    difftastic = {
      enable = true;
      git.enable = true;
    };
    git.settings.diff.algorithm = "histogram";
  };
}
