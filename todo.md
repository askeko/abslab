# Long term

- treefmt for git/hooks.nix and language formatting in vim
- git hooks

# Theming

Apps Noctalia has no builtin template for use their own defaults. Theme them
with Noctalia user templates (`theme.templates.user.<id>`) so they follow
theme switches, one app at a time:

- zathura
- imv
- Neovim
- zsh autosuggestion colour
- Vesktop (Noctalia has a community Discord template, fetched from
  api.noctalia.dev — or write a user template for a Vencord theme)
- Spotify: the official client can't be themed as-is. Noctalia's community
  Spotify template targets Spicetify (patches the official client; on Nix
  that's the spicetify-nix flake), or switch to a themable alternative client
- Firefox: Pywalfox extension, driven by Noctalia's built-in `firefox-theme`
  host (community template `pywalfox-beta4`)
- Obsidian: CSS snippet in the vault's `.obsidian/snippets/` (community
  `obsidian.css` as a user template)
- Steam: needs the Millennium mod framework + Material Theme (community Steam
  template) — check it's worth patching the client
- MangoHud (low priority)
