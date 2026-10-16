{ lib, ... }:
{
  # Lists Hyprland's binds and what they do, from each bind's description.
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      keybinds = pkgs.writeShellApplication {
        name = "keybinds";
        runtimeInputs = [
          pkgs.hyprland
          pkgs.jq
          hmArgs.config.programs.noctalia.package
        ];
        text = ''
          hyprctl -j binds | jq -r '
              def mods: .modmask as $m
                  | [[64, "Super"], [4, "Ctrl"], [8, "Alt"], [1, "Shift"]]
                  | map(select(($m / .[0] | floor) % 2 == 1) | .[1]);
              .[]
              | select(.has_description)
              | ((mods + [.key]) | join("+")) + "\t" + .description
          ' | noctalia dmenu -p Keybinds >/dev/null
        '';
      };
    in
    {
      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + SHIFT + slash", app("${lib.getExe keybinds}"), "Show keybinds")
      '';
    };
}
