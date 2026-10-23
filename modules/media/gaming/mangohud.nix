{ lib, ... }:
{
  flake.modules.homeManager.gui = {
    programs.mangohud.enable = true;

    # MangoHud has no include, so Noctalia renders its whole config from
    # mangohud-noctalia/MangoHud.conf (settings and colours); other MangoHud
    # settings go in that file too, not in programs.mangohud.settings. It
    # reloads the file on change, so running games follow theme switches.
    programs.noctalia.settings.theme.templates.user.mangohud = {
      input_path = lib.mkDefault "${./mangohud-noctalia/MangoHud.conf}";
      output_path = lib.mkDefault "$XDG_CONFIG_HOME/MangoHud/MangoHud.conf";
    };
  };
}
