{ config, ... }:
{
  flake.modules.homeManager.base.programs.git = {
    settings = {
      user = {
        email = config.flake.meta.owner.email;
        name = config.flake.meta.owner.name;
      };
      init.defaultBranch = "main";
      push = {
        default = "current";
        # The first push of a new branch sets its upstream.
        autoSetupRemote = true;
      };
      commit.verbose = true;
      branch.sort = "-committerdate";
      tag.sort = "taggerdate";
    };
  };
}
