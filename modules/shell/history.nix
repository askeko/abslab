{
  # Shared between terminals; duplicates, lines starting with a space and
  # `rm` commands aren't saved. Ctrl+R is fzf's history search (shell/fzf.nix).
  flake.modules.homeManager.base.programs.zsh = {
    history = {
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      ignorePatterns = [ "rm *" ];
    };
    initContent = ''
      bindkey '^[;' up-line-or-search
    '';
  };
}
