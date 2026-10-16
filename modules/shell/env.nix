{
  # Own scripts first on PATH, and history/cache files out of ~.
  flake.modules.homeManager.base = hmArgs: {
    home.sessionPath = [ "$HOME/.local/bin" ];

    home.sessionVariables = with hmArgs.config.xdg; {
      LESSHISTFILE = "-";
      NODE_REPL_HISTORY = "${stateHome}/node_repl_history";
      NPM_CONFIG_CACHE = "${cacheHome}/npm";
      PYTHON_HISTORY = "${stateHome}/python_history";
      DOCKER_CONFIG = "${configHome}/docker";
    };
  };
}
