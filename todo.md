# Features

- Hide notifications automatically during screencasts: Hyprland emits a
  `screencast` event (socket2 / Lua event handler) — turn Noctalia's
  do-not-disturb on when sharing starts and off when it stops.

# Long term

- treefmt for git/hooks.nix and language formatting in vim
- git hooks

# Theming

Apps Noctalia has no builtin template for use their own defaults. Theme them
with Noctalia user templates (`theme.templates.user.<id>`) so they follow
theme switches, one app at a time:

- yazi
- bat
- fzf
- zathura
- imv
- Neovim
- zsh autosuggestion colour
- MangoHud (low priority)
