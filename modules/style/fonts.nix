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
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.symbols-only
        noto-fonts
        noto-fonts-color-emoji
      ];
      fonts.fontconfig = {
        enable = true;
        defaultFonts = with config.flake.meta.fonts; {
          sansSerif = [ sansSerif.name ];
          serif = [ serif.name ];
          monospace = [ monospace.name ];
          emoji = [ emoji.name ];
        };
      };
    };
}
