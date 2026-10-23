{ lib, inputs, ... }:
{
  flake.modules.homeManager.base =
    hmArgs@{ pkgs, ... }:
    {
      programs.claude-code = {
        enable = lib.mkDefault true;
        # sadjow/claude-code-nix: updated hourly, unlike nixpkgs. The flake
        # instantiates its own pkgs with allowUnfree, so no allowlist entry needed.
        package = lib.mkDefault inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      };

      programs.codex.enable = lib.mkDefault true;

      # CODEX_HOME is ~/.config/codex (preferXdgDirectories), but HM only creates
      # it when it writes config there. Codex keeps its login and sessions in it.
      home.activation.createCodexHome = hmArgs.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run install -d -m 0700 $VERBOSE_ARG "${hmArgs.config.xdg.configHome}/codex"
      '';

      # Sandboxing for coding agents (Claude Code's sandbox mode; socat, its
      # network relay, comes from networking/utils.nix).
      home.packages = [ pkgs.bubblewrap ];
    };

  flake.modules.homeManager.gui.programs.noctalia.settings.theme.templates.user = {
    # Claude Code in the active theme's colours: its light/dark base from
    # Noctalia's mode, every colour token overridden from the palette (diff
    # backgrounds stay the base's: they need tints templates can't blend). Not
    # the dark-ansi/light-ansi presets: they assume conventional ANSI slots,
    # which light palettes swap. Claude Code reloads it live; selected once with
    # /theme -> Noctalia.
    claude_code = {
      input_path = lib.mkDefault "${./claude-code-noctalia/theme.json}";
      output_path = lib.mkDefault "~/.claude/themes/noctalia.json";
    };

    # Codex's code highlighting: tokyonight's tmTheme (tokyonight.nvim
    # extras/sublime/tokyonight_night.tmTheme) with its colours swapped for
    # Noctalia's, mapped like Neovim's on_colors (lazyvim/noctalia/theme.lua);
    # orange, which Noctalia lacks, is bright red. Codex reads it at session
    # start; selected once with [tui] theme = "noctalia" in its config.toml.
    codex = {
      input_path = lib.mkDefault "${./codex-noctalia/noctalia.tmTheme}";
      output_path = lib.mkDefault "$XDG_CONFIG_HOME/codex/themes/noctalia.tmTheme";
    };
  };
}
