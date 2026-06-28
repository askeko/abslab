# LazyVim styling from flake.meta.theme
{ config, ... }:
let
  theme = config.flake.meta.theme;
  cs = theme.schemes.${theme.scheme}.lazyvim;
in
{
  # osConfig is the host NixOS config, passed by home-manager's NixOS module (and
  # by each specialisation, with its own polarity). Read the live mode from
  # osConfig.stylix.polarity so the light/dark specialisation (theme.nix) re-themes
  # nvim alongside the rest of the desktop. Standalone HM (the flake checks) has no
  # osConfig, so fall back to the static flake.meta.theme.mode.
  flake.modules.homeManager.lazyvim =
    {
      config,
      lib,
      osConfig ? null,
      ...
    }:
    let
      mode = if osConfig != null && osConfig ? stylix then osConfig.stylix.polarity else theme.mode;
    in
    {
      programs.lazyvim.plugins.colorscheme = ''
        return {
          ${cs.spec mode},
          { "LazyVim/LazyVim", opts = { colorscheme = "${cs.name}" } },
        }
      '';

      # vim.loader caches bytecode keyed on {mtime, size}, but every Nix store file
      # has mtime 1970 — so a colorscheme.lua whose *content* changes without its
      # byte-size changing (e.g. kanagawa dragon<->lotus, both 156 bytes; or
      # catppuccin mocha<->latte) is served stale and nvim keeps the old theme.
      # Drop the loader cache on activation so the new colorscheme always takes
      # effect on the next launch. Also fires on light/dark specialisation switch.
      home.activation.invalidateNvimLoaderCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run rm -rf $VERBOSE_ARG "${config.xdg.cacheHome}/nvim/luac"
      '';
    };
}
