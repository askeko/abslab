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
      emoji = config.flake.meta.fonts.emoji.name;
    in
    {
      # Extra symbols
      fonts.packages = [
        pkgs.nerd-fonts.symbols-only
        pkgs.dejavu_fonts
      ];

      # Symbols fallback for generic monospace requests
      fonts.fontconfig.defaultFonts = {
        monospace = lib.mkAfter [
          "Symbols Nerd Font Mono"
          "DejaVu Sans Mono"
          emoji
        ];
        sansSerif = lib.mkAfter [
          "Symbols Nerd Font"
          emoji
        ];
        serif = lib.mkAfter [
          "Symbols Nerd Font"
          emoji
        ];
      };
    };
}
