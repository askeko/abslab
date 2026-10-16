{
  flake.modules.homeManager.base.programs = {
    tealdeer = {
      enable = true;
      settings = {
        display.use_pager = true;
        # Fetch the pages on first use and refresh them every 30 days.
        updates.auto_update = true;
      };
    };
    info.enable = true;
  };
}
