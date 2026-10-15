{
  perSystem =
    { pkgs, ... }:
    {
      make-shells.default.packages = with pkgs; [
        just
        statix
        deadnix
        nixfmt
      ];
      # Skip under direnv (`use flake`): it evals the hook in its own shell,
      # so exec'ing zsh there would replace direnv's process.
      make-shells.default.shellHook = ''
        if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
          exec zsh
        fi
      '';
    };
}
