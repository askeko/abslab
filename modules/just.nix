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
      make-shells.default.shellHook = "exec zsh";
    };
}
