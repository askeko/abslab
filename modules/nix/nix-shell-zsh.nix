{ lib, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      # --run goes through bash, which bumps SHLVL before zsh bumps it again
      # (+2 per nesting level); hand bash's increment back so the inner zsh
      # sits exactly one level deeper.
      programs.zsh.shellAliases.nix-shell = "nix-shell --run 'SHLVL=$((SHLVL-1)) exec ${lib.getExe pkgs.zsh}'";
    };
}
