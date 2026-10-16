{
  flake.modules.homeManager.base.programs.zsh = {
    defaultKeymap = "viins";
    initContent = ''
      export KEYTIMEOUT=1

      # Vim keys in the completion menu.
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey -v '^?' backward-delete-char

      # Block cursor in normal mode, beam in insert mode.
      zle-keymap-select() {
          case $KEYMAP in
          vicmd) echo -ne '\e[1 q' ;;
          viins | main) echo -ne '\e[5 q' ;;
          esac
      }
      zle -N zle-keymap-select
      zle-line-init() {
          zle -K viins
          echo -ne '\e[5 q'
      }
      zle -N zle-line-init
      echo -ne '\e[5 q'
      preexec() { echo -ne '\e[5 q'; }
    '';
  };
}
