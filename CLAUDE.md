# abslab — Claude Code guidance

## Git policy

**NEVER run `git add`, `git commit`, or `git push`** — the user manages all git
operations themselves. Do not stage, commit, or push anything under any
circumstances, even if asked mid-task; instead make the file changes and let the
user handle git. Read-only git commands (`git status`, `git diff`, `git log`) are fine.

## Project overview

NixOS configuration using **flake-parts** + **import-tree** with the **dendritic module pattern**.
All `.nix` files under `modules/` are auto-loaded by `import-tree ./modules` — no manual import list to maintain.

Hosts: `lazarus` (desktop, inherits `pc`), `halflight` (laptop, inherits `laptop → pc`).
Owner username: `absentia`. Home directory: `/home/absentia`.

## Module system

### Namespaces

| Attribute | Purpose |
|---|---|
| `flake.modules.nixos.<key>` | NixOS module |
| `flake.modules.homeManager.<key>` | Home Manager module |
| `flake.meta.*` | Project-wide metadata (owner, fonts, etc.) |
| `configurations.nixos.<hostname>.module` | Host entry point |

### How HM is wired

`modules/home-manager/nixos.nix` wires HM into NixOS modules:
- `base` NixOS module → loads `homeManager.base` and `homeManager.lazyvim` for all users
- `pc` NixOS module → loads `homeManager.gui`
- `laptop` NixOS module → loads `homeManager.laptop`

To add a new HM module to all desktop hosts, add it to `pc` in that file (or create a new NixOS module key and import it in host imports).

### Module keys

Keys are simple attribute names — not slash-delimited strings:

```nix
flake.modules.nixos.myFeature = { pkgs, ... }: { ... };
flake.modules.homeManager.myFeature = hmArgs: { ... };
```

### Referencing other modules

Always route through the tree — never use relative `../` imports:

```nix
{ config, ... }: {
  flake.modules.nixos.myFeature = {
    imports = [ config.flake.modules.nixos.otherFeature ];
  };
}
```

### Reading metadata

```nix
{ config, ... }: {
  flake.modules.nixos.myFeature = {
    fonts.fontconfig.defaultFonts.monospace = [ config.flake.meta.fonts.monospace.name ];
  };
}
```

### Host registration

```nix
# modules/hosts/<name>/imports.nix
{ config, ... }: {
  configurations.nixos.<name>.module = {
    imports = with config.flake.modules.nixos; [ efi pc ];
  };
}
```

## Dendritic module rules

These rules are defined in `modules/docs/module-authoring.md` — read it for examples.

1. **Import to enable** — no top-level `enable` options. Importing a module activates it with good defaults.
2. **Co-locate NixOS + HM** — when a feature spans both layers, put both `flake.modules.nixos.x` and `flake.modules.homeManager.x` in the same file.
3. **`lib.mkDefault` on all values** — so hosts can override without `lib.mkForce`.
4. **Options namespace** — use `options.services.<name>` for nixpkgs-style services; use `options.flake.meta.*` for project-wide data; avoid inventing new top-level namespaces unless necessary.
5. **Scripts** — inline if ~20 lines or fewer; otherwise put in a sibling `scripts/` directory and load with `pkgs.writeShellApplication` or `builtins.readFile`.
6. **No `enable` guards** — never wrap `config = lib.mkIf cfg.enable { ... }` as the primary activation pattern.

## Directory conventions

```
modules/
  style/        ← visual theming (fonts live here; new theme modules go here)
  window-manager/ ← compositor, wallpaper, cursor, waybar, etc.
  hosts/<name>/ ← per-host files (imports, monitors, hardware, etc.)
  home-manager/ ← HM wiring into NixOS
  docs/         ← authoritative pattern docs (read-only reference)
```

## Theming (Stylix)

Stylix-based declarative theming controlled by `flake.meta.theme.scheme` / `flake.meta.theme.mode` (active: gruvbox / dark).

- **Stylix is a flake input** (`inputs.stylix`); the NixOS module is imported in `theme.nix`.
- **`modules/style/theme.nix`** holds the Stylix wiring and the `flake.meta.theme.schemes` registry (one entry feeds both Stylix's base16 scheme and LazyVim); it augments the existing `nixos.pc` and `homeManager.gui` namespaces — no new module keys.
- **`modules/style/fonts.nix`** completes the fontconfig fallback chain (Symbols NF Mono → DejaVu Sans Mono → Noto Color Emoji) so kitty/etc. render dingbats/arrows/emoji — do **not** reintroduce a kitty `symbol_map`.
- **`modules/window-manager/wallpaper.nix`** stays on `hyprpaper` (decision: no swww migration): rofi `wallpaper-picker` + `wallpaper-restore`, and maintains a `~/.local/state/theme/current-wallpaper` symlink that hyprlock reads so the lock screen follows the live wallpaper.
- Theme options live under `flake.meta.theme.*` (consistent with `flake.meta.fonts`), not a new `my.*` namespace.
- **Discord stays the official client** (not Vesktop): Vesktop's Electron 40 breaks per-window screenshare. Don't re-attempt the swap.

## Misc

- Pipe operator `|>` is enabled globally via `nixConfig.extra-experimental-features`.
- `flake-parts` modules system: see `modules/flake-parts.nix` and `modules/configurations/nixos.nix`.
- `modules/docs/dendritic-core.md` and `modules/docs/module-authoring.md` are the canonical pattern references — read them before authoring new modules.
