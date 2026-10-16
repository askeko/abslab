{ lib, ... }:
{
  # Menu completion (hjkl to move), case-insensitive, hidden files included;
  # carapace adds completions for tools without their own.
  flake.modules.homeManager.base = {
    programs = {
      zsh = {
        enableCompletion = true;
        initContent = lib.mkOrder 550 ''
          zstyle ':completion:*' menu select
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zmodload zsh/complist
          _comp_options+=(globdots)
        '';
      };
      carapace.enable = true;
    };
  };
}
