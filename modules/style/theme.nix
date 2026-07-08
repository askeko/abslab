{ config, inputs, ... }:
let
  meta = config.flake.meta;
in
{
  flake.meta.theme = {
    scheme = "tokyonight-night";
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
      kanagawa = {
        base16 = {
          dark = "kanagawa-dragon";
          light = "kanagawa-lotus";
        };
        lazyvim = {
          name = "kanagawa";
          spec =
            mode:
            ''{ "rebelot/kanagawa.nvim", opts = { theme = "${
              if mode == "dark" then "dragon" else "lotus"
            }", background = { dark = "dragon", light = "lotus" } }, init = function() vim.o.background = "${mode}" end }'';
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
      # tokyonight dark variants: moon (default), storm, night. Light is always
      # Day. Switch dark variant by pointing `scheme` at another entry (rebuild);
      # light<->dark stays the instant specialisation toggle.
      tokyonight = {
        base16 = {
          dark = "tokyo-night-moon";
          light = "tokyo-night-light";
        };
        lazyvim = {
          name = "tokyonight";
          spec =
            mode:
            ''{ "folke/tokyonight.nvim", opts = { style = "moon", light_style = "day" }, init = function() vim.o.background = "${mode}" end }'';
        };
      };
      tokyonight-storm = {
        base16 = {
          dark = "tokyo-night-storm";
          light = "tokyo-night-light";
        };
        lazyvim = {
          name = "tokyonight";
          spec =
            mode:
            ''{ "folke/tokyonight.nvim", opts = { style = "storm", light_style = "day" }, init = function() vim.o.background = "${mode}" end }'';
        };
      };
      tokyonight-night = {
        base16 = {
          dark = "tokyo-night-dark";
          light = "tokyo-night-light";
        };
        lazyvim = {
          name = "tokyonight";
          spec =
            mode:
            ''{ "folke/tokyonight.nvim", opts = { style = "night", light_style = "day" }, init = function() vim.o.background = "${mode}" end }'';
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
      # Resolve the active scheme's base16 YAML for a given mode: prefer a local
      # ./schemes/<stem>.yaml (e.g. kanagawa-lotus) when present, otherwise resolve
      # the stem against pkgs.base16-schemes.
      base16FileFor =
        mode:
        let
          stem = meta.theme.schemes.${meta.theme.scheme}.base16.${mode};
          localScheme = ./schemes + "/${stem}.yaml";
        in
        if builtins.pathExists localScheme then
          localScheme
        else
          "${pkgs.base16-schemes}/share/themes/${stem}.yaml";
      base16File = base16FileFor meta.theme.mode;
      # The opposite polarity, exposed below as a switchable specialisation so
      # light<->dark is an instant activation instead of a full rebuild.
      otherMode = if meta.theme.mode == "dark" then "light" else "dark";
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
              firefox.firefoxGnomeTheme.enable = true;
            };
          };
        }
      ];

      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = base16File;
        polarity = meta.theme.mode;

        # For Inkspace to not require double space and build time with specializations
        targets.gtksourceview.enable = false;

        # Slight terminal translucency
        opacity.terminal = lib.mkDefault 0.9;
        # The live desktop wallpaper is managed by awww (window-manager/wallpaper.nix)
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

      # Opposite-polarity build, kept resident so light<->dark is an instant
      # activation rather than a rebuild:
      #   sudo /run/current-system/specialisation/${otherMode}/bin/switch-to-configuration switch
      specialisation.${otherMode}.configuration = {
        stylix.base16Scheme = lib.mkForce (base16FileFor otherMode);
        stylix.polarity = lib.mkForce otherMode;
      };
    };

}
