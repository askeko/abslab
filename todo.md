# Long term

- treefmt for git/hooks.nix and language formatting in vim
- git hooks
- Theme menu: `noctalia dmenu` listing Noctalia's built-in themes, running
  `noctalia msg color-scheme-set builtin <name>`, bound to e.g. `Mod+Ctrl+S`
  (light/dark stays on `Mod+Shift+S`). A picked theme persists in Noctalia's
  settings.toml over `theme.builtin` from Nix. Neovim follows the selected
  palette through Tokyo Night's `on_colors` callback.
