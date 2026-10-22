{ lib, ... }:
{
  flake.modules.homeManager.base = {
    programs.bat.enable = true;
    home.shellAliases.cat = "bat";
  };

  # Noctalia colours: its community bat template, vendored in bat-noctalia/
  # (noctalia-dev/community-templates@d5bd193, bat/) without its apply.sh hook,
  # which would edit bat's config; the theme is selected here instead. bat only
  # sees theme changes after rebuilding its cache, run from an empty directory
  # like Home Manager's activation does (bat#1726).
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    {
      programs.noctalia.settings.theme.templates.user.bat = {
        input_path = lib.mkDefault "${./bat-noctalia/bat.tmTheme}";
        output_path = lib.mkDefault "$XDG_CONFIG_HOME/bat/themes/noctalia.tmTheme";
        post_hook = lib.mkDefault "cd ${pkgs.emptyDirectory} && ${lib.getExe hmArgs.config.programs.bat.package} cache --build";
      };

      programs.bat.config.theme = lib.mkDefault "noctalia";
    };
}
