{ lib, ... }:
{
  flake.modules.homeManager.gui = hmArgs: {
    programs.obsidian = {
      enable = true;
      vaults.absentia-vault.target = "docs/absentia-vault";
    };

    # Noctalia colours: its community obsidian snippet, vendored in
    # obsidian-noctalia/ (noctalia-dev/community-templates@a38fc33, obsidian/),
    # rendered into each declared vault that exists on this host. Its apply.sh
    # (which searches $HOME for vaults and edits their appearance.json) is
    # dropped: enable the snippet once in Settings -> Appearance -> CSS
    # snippets, since declaring it would make appearance.json read-only.
    programs.noctalia.settings.theme.templates.user = lib.mapAttrs' (
      name: vault:
      let
        dir = "${hmArgs.config.home.homeDirectory}/${vault.target}/.obsidian";
      in
      lib.nameValuePair "obsidian_${name}" {
        input_path = lib.mkDefault "${./obsidian-noctalia/obsidian.css}";
        output_path = lib.mkDefault "${dir}/snippets/noctalia.css";
        requires_path = lib.mkDefault dir;
      }
    ) hmArgs.config.programs.obsidian.vaults;
  };

  nixpkgs.config.allowUnfreePackages = [
    "obsidian"
  ];
}
