{
  flake.modules.homeManager.base.programs.zsh = {
    autosuggestion.enable = true;
    initContent = ''
      bindkey '^[^M' autosuggest-execute
    '';
  };

  # Brighter autosuggestion highlight text color
  flake.modules.homeManager.gui = hmArgs: {
    programs.zsh.autosuggestion.highlight = "fg=${hmArgs.config.lib.stylix.colors.withHashtag.base04}";
  };
}
