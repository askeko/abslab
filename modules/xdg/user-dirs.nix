{ config, ... }:
let
  owner = config.flake.meta.owner.username;
in
{
  flake.modules.homeManager.base =
    { config, ... }:
    {
      home.preferXdgDirectories = true;
      xdg = {
        enable = true;
        userDirs =
          let
            tmp = "${config.home.homeDirectory}/tmp";
          in
          {
            enable = true;
            createDirectories = true;
            desktop = tmp;
            documents = tmp;
            download = tmp;
            music = tmp;
            pictures = tmp;
            projects = tmp;
            publicShare = "${config.home.homeDirectory}/public";
            templates = "${config.home.homeDirectory}/templates";
            videos = tmp;
            setSessionVariables = true;
          };
      };
    };

  # ~/tmp is the catch-all for the XDG dirs above — disposable scratch. It
  # persists across reboots but entries older than 7 days are auto-removed
  # (systemd-tmpfiles-clean.timer, daily).
  flake.modules.nixos.base =
    { config, ... }:
    {
      systemd.tmpfiles.rules = [
        "d ${config.users.users.${owner}.home}/tmp 0700 ${owner} users 7d"
      ];
    };
}
