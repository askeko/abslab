{ config, inputs, ... }:
let
  meta = config.flake.meta;
in
{
  flake.meta.theme = {
    scheme = "rose-pine";
    mode = "dark";
    wallpaper.path = "/home/${config.flake.meta.owner.username}/pictures/wallpapers";

    # Single source of truth for colour schemes.
    #   base16  — base16-schemes filename per mode (consumed by Stylix below)
    #   lazyvim — `:colorscheme` name + a lua plugin-spec builder (consumed by
    #             modules/style/lazyvim.nix)
    # Add a scheme here once and every themed tool can use it.
    schemes = {
      catppuccin = {
        base16 = {
          dark = "catppuccin-mocha";
          light = "catppuccin-latte";
        };
        lazyvim = {
          name = "catppuccin";
          spec =
            mode:
            ''{ "catppuccin/nvim", opts = { flavour = "${if mode == "dark" then "mocha" else "latte"}" } }'';
        };
      };
      gruvbox = {
        base16 = {
          dark = "gruvbox-dark-medium";
          light = "gruvbox-light-medium";
        };
        lazyvim = {
          name = "gruvbox";
          spec =
            mode:
            ''{ "ellisonleao/gruvbox.nvim", opts = { contrast = "medium" }, init = function() vim.o.background = "${mode}" end }'';
        };
      };
      rose-pine = {
        base16 = {
          dark = "rose-pine";
          light = "rose-pine-dawn";
        };
        lazyvim = {
          name = "rose-pine";
          spec =
            mode:
            ''{ "rose-pine/neovim", name = "rose-pine", opts = { variant = "${
              if mode == "dark" then "main" else "dawn"
            }" }, init = function() vim.o.background = "${mode}" end }'';
        };
      };
    };
  };

  flake.modules.nixos.pc =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      base16Stem = meta.theme.schemes.${meta.theme.scheme}.base16.${meta.theme.mode};
    in
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      # Stylix kmscon module references services.kmscon.config which was removed in nixpkgs
      disabledModules = [ "${inputs.stylix}/modules/kmscon/nixos.nix" ];

      # Custom stylix stuff
      home-manager.sharedModules = [
        {
          stylix = {
            enableReleaseChecks = false;

            targets = {
              waybar.enable = false; # palette vars in waybar.nix
              neovim.enable = false; # LazyVim manages its own colorscheme
              hyprlock.enable = false; # background/colors managed in screenlock.nix
              firefox.profileNames = [ "primary" ];
              firefox.firefoxGnomeTheme.enable = true; # GNOME-style chrome + stylix-colored userChrome
            };
          };
        }
      ];

      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${base16Stem}.yaml";
        polarity = meta.theme.mode;

        # Slight terminal translucency
        opacity.terminal = lib.mkDefault 0.9;
        # The live desktop wallpaper is managed by hyprpaper (window-manager/wallpaper.nix)
        # from ~/pictures, which a flake's pure eval can't reference. Stylix still requires
        # an image, so feed it a solid pixel generated from the active scheme's background
        # colour - it tracks scheme/mode automatically instead of pinning catppuccin.
        image = "${config.lib.stylix.pixel "base00"}";

        cursor = {
          package = lib.mkDefault pkgs.borealis-cursors;
          name = lib.mkDefault "Borealis-cursors";
          size = lib.mkDefault 36;
        };

        fonts = {
          serif = {
            package = lib.mkDefault pkgs.noto-fonts;
            name = lib.mkDefault meta.fonts.serif.name;
          };
          sansSerif = {
            package = lib.mkDefault pkgs.noto-fonts;
            name = lib.mkDefault meta.fonts.sansSerif.name;
          };
          monospace = {
            package = lib.mkDefault pkgs.nerd-fonts.fira-code;
            name = lib.mkDefault meta.fonts.monospace.name;
          };
          emoji = {
            package = lib.mkDefault pkgs.noto-fonts-color-emoji;
            name = lib.mkDefault meta.fonts.emoji.name;
          };
          sizes = {
            applications = lib.mkDefault meta.fonts.sizes.applications;
            desktop = lib.mkDefault meta.fonts.sizes.desktop;
            terminal = lib.mkDefault meta.fonts.sizes.terminal;
          };
        };
      };
    };

}
