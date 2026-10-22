{ lib, ... }:
{
  # Ctrl+T inserts a file, Alt+C changes directory, Ctrl+R searches history.
  flake.modules.homeManager.base.programs.fzf.enable = true;

  # Noctalia colours: the --color options of its community fzf template
  # (noctalia-dev/community-templates@d5bd193, fzf/fzf.sh), in fzf-noctalia/
  # without the shell wrapper that appends them to FZF_DEFAULT_OPTS at startup.
  # fzf reads FZF_DEFAULT_OPTS_FILE on every run instead, so open shells follow
  # theme switches. It fails when the file is missing, hence the check.
  flake.modules.homeManager.gui =
    hmArgs:
    let
      colors = "${hmArgs.config.xdg.configHome}/fzf/noctalia-colors";
      useColors = ''
        if [ -r "${colors}" ]; then export FZF_DEFAULT_OPTS_FILE="${colors}"; fi
      '';
    in
    {
      programs = {
        noctalia.settings.theme.templates.user.fzf = {
          input_path = lib.mkDefault "${./fzf-noctalia/fzf-colors}";
          output_path = lib.mkDefault colors;
        };
        zsh.initContent = useColors;
        bash.initExtra = useColors;
      };
    };
}
