{
  flake.modules.homeManager.base.programs = {
    bash.enable = true;

    # vi mode for bash and other readline programs, with the same cursor
    # shapes as zsh.
    readline = {
      enable = true;
      variables = {
        editing-mode = "vi";
        show-mode-in-prompt = true;
        vi-ins-mode-string = ''\1\e[6 q\2'';
        vi-cmd-mode-string = ''\1\e[2 q\2'';
      };
      extraConfig = ''
        $if mode=vi
        set keymap vi-command
        Control-l: clear-screen
        Control-a: beginning-of-line
        set keymap vi-insert
        Control-l: clear-screen
        Control-a: beginning-of-line
        $endif
      '';
    };
  };
}
