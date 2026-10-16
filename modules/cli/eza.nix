{
  flake.modules.homeManager.base = {
    programs.eza.enable = true;

    home.shellAliases =
      let
        eza = "eza --color=always --group-directories-first";
      in
      {
        ls = "${eza} -al";
        la = "${eza} -a";
        ll = "${eza} -l";
        lt = "${eza} -aT";
      };
  };
}
