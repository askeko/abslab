# Dendritic Core Concepts

- **Every file is a flake-parts module**: `import-tree ./modules` loads every `.nix` file under `modules/` as a top-level flake-parts module; there is no import list and no file imports a sibling by path.
- **Features export deferred modules**: a file contributes to `flake.modules.nixos.<name>` and/or `flake.modules.homeManager.<name>` (simple attribute names such as `base`, `pc`, `gui`, `laptop`). Several files may add to the same name; the module system merges them, so a feature can extend a shared profile or another module (e.g. its persisted state into `nixos.impermanence`) from its own file.
- **Hosts compose modules**: a host is `configurations.nixos.<host>.module`, a deferred module that imports values from `config.flake.modules.nixos` (`modules/hosts/<host>/imports.nix`); `modules/configurations/nixos.nix` turns each into a `nixosConfigurations.<host>` with `lib.nixosSystem`. Home Manager is wired by NixOS modules (`modules/home-manager/nixos.nix`), not by a separate loader.
- **Shared values through the top-level config**: project-wide data lives in `flake.meta` and is read as `config.flake.meta.*`; flake inputs come from the flake-parts module arguments (`{ inputs, ... }`). Every value is reachable this way, so nothing is passed through `specialArgs`.
- **perSystem outputs**: packages, dev shells and checks are defined under `perSystem`.
