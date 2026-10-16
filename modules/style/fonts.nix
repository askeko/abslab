{ config, ... }:
{
  flake.meta.fonts = {
    sansSerif.name = "Noto Sans";
    serif.name = "Noto Serif";
    monospace.name = "FiraCode Nerd Font Mono";
    emoji.name = "Noto Color Emoji";
    sizes = {
      applications = 12;
      desktop = 12;
      terminal = 12;
    };
  };

  flake.modules.nixos.pc =
    { pkgs, lib, ... }:
    let
      inherit (config.flake.meta) fonts;
    in
    {
      fonts.packages = with pkgs; [
        noto-fonts
        nerd-fonts.fira-code
        noto-fonts-color-emoji
        # Symbol fallbacks
        nerd-fonts.symbols-only
        dejavu_fonts
      ];

      # Each family falls back to the Nerd Font symbols and colour emoji.
      fonts.fontconfig.defaultFonts = lib.mapAttrs (_: lib.mkDefault) {
        monospace = [
          fonts.monospace.name
          "Symbols Nerd Font Mono"
          "DejaVu Sans Mono"
          fonts.emoji.name
        ];
        sansSerif = [
          fonts.sansSerif.name
          "Symbols Nerd Font"
          fonts.emoji.name
        ];
        serif = [
          fonts.serif.name
          "Symbols Nerd Font"
          fonts.emoji.name
        ];
        emoji = [ fonts.emoji.name ];
      };
    };
}
