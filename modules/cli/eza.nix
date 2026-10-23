{ inputs, ... }:
{
  flake.modules.homeManager.base = {
    programs.eza.enable = true;
    # Rosé Pine's eza port.
    xdg.configFile."eza/theme.yml".source = "${inputs.rose-pine-eza}/dist/rose-pine.yml";

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
