{ inputs, lib, ... }:
{
  flake.modules.homeManager.base = {
    programs.bat = {
      enable = true;
      themes.rose-pine = {
        src = inputs.rose-pine-tm-theme;
        file = "dist/rose-pine.tmTheme";
      };
      config.theme = lib.mkDefault "rose-pine";
    };
    home.shellAliases.cat = "bat";
  };
}
