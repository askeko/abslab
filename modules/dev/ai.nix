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

  # Claude Code's own light or dark theme, following Noctalia's mode: a custom
  # theme that only picks the base (no colour overrides, unlike the community
  # template's Material roles). Claude Code reloads it live; selected once with
  # /theme -> Noctalia.
  flake.modules.homeManager.gui.programs.noctalia.settings.theme.templates.user.claude_code = {
    input_path = lib.mkDefault "${./claude-code-noctalia/theme.json}";
    output_path = lib.mkDefault "~/.claude/themes/noctalia.json";
  };
}
