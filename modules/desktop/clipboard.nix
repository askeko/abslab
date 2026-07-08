{
  flake.modules.homeManager.gui =
    hmArgs@{
      lib,
      pkgs,
      ...
    }:
    let
      rofi-cliphist = pkgs.writeShellApplication {
        name = "rofi-cliphist";
        runtimeInputs = [
          hmArgs.config.services.cliphist.package
          hmArgs.config.programs.rofi.package
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

      home.packages = with pkgs; [
        wl-clipboard-rs
      ];

      programs.niri.settings.binds."Mod+P".action.spawn = lib.getExe rofi-cliphist;
    };
}
