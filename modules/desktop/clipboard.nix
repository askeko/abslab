{
  flake.modules = {
    homeManager.gui =
      {
        config,
        pkgs,
        ...
      }:
      let
        rofi-cliphist = pkgs.writeShellApplication {
          name = "rofi-cliphist";
          runtimeInputs = [
            config.services.cliphist.package
            config.programs.rofi.package
          ];
          text = ''
            prompt=' 󰆏 '
            content=$(cliphist list | rofi -dmenu -p "$prompt")
            decoded=$(cliphist decode <<<"$content")

            echo "$decoded" | wl-copy
          '';
        };
      in
      {
        services.cliphist.enable = true;

        home.packages = [
          pkgs.wl-clipboard-rs
          # Added to packages to be called in Niri config.kdl
          rofi-cliphist
        ];
      };
  };
}
