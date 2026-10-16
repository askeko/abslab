{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      inherit (pkgs) rofimoji;
    in
    {
      home.packages = [ rofimoji ];

      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + U", cmd(ipc .. "panel-toggle launcher /emo"), "Emoji picker")
        bind(mod .. " + SHIFT + U", app("${lib.getExe rofimoji} --files all"), "Character picker")
      '';
    };
}
