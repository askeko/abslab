# Fixes
- Fix Just

# Niri migration follow-ups
- Automatic notification privacy during screencasts: the mako privacy mode was
  toggled by a Hyprland socket2 listener (handle-hyprland-screencast); niri has
  no screencast event in its event stream — watch the ScreenCast portal over
  D-Bus, or check newer niri releases. Manual toggle still works via
  notification-privacy-on/off.
- halflight projector mirroring: niri has no output mirroring; use wl-mirror
  when presenting (the old Hyprland config mirrored Samsung/Lightware outputs
  to eDP-1).

# Extras

- torrenting
- vpn
- office packages
- gaming
- virtualization: vm

# Long term

- treefmt for git/hooks.nix and language formatting in vim
- git hooks
- secret management (sops)

# Theming

Themable programs

## Window Manager / Compositor

- Niri
- Hyprlock

## Bar / Launcher / Notifications

- Waybar
- Rofi (launcher, cliphist, rofi-rbw, pinentry-rofi)
- Mako

## Terminal / Shell

- Kitty
- Starship
- Zsh
  - zsh-syntax-highlighting
- Bat

## Editor

- Lazyvim

## File / Document / Image Tools

- Yazi
- Zathura
- Satty
- imv
- difftastic

## Browser / Third-party apps

- Firefox
- Discord
- Obsidian
- Spotify

## Toolkits / System-wide

- GTK
- Qt
- Pointer cursor
- Fonts (fontconfig)

## Boot / Login

- Plymouth
- Tuigreet / greetd
