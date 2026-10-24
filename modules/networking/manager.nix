{ config, lib, ... }:
{
  flake.modules = {
    nixos.pc = {
      networking.networkmanager.enable = true;
      users.users.${config.flake.meta.owner.username}.extraGroups = [ "networkmanager" ];
    };

    # Saved connections and their state survive the root wipe.
    nixos.impermanence.environment.persistence."/persist".directories = [
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
    ];

    # nmtui (and other newt programs, like whiptail) in the terminal's own
    # colours. newt's defaults assume a VGA palette (light "lightgray" windows
    # on deep blue), which kitty's pastel Rosé Pine palette turns into pastel
    # on pastel. "default" is the terminal's foreground/background, cyan the
    # accent.
    homeManager.gui.home.sessionVariables.NEWT_COLORS = lib.mkDefault (
      lib.concatStringsSep ";" [
        "root=default,default"
        "roottext=default,default"
        "helpline=default,default"
        "window=default,default"
        "border=cyan,default"
        "shadow=black,black"
        "title=cyan,default"
        "label=default,default"
        "textbox=default,default"
        "acttextbox=black,cyan"
        "entry=default,black"
        "disentry=gray,default"
        "button=cyan,default"
        "actbutton=black,cyan"
        "compactbutton=default,default"
        "checkbox=default,default"
        "actcheckbox=black,cyan"
        "listbox=default,default"
        "actlistbox=black,cyan"
        "sellistbox=cyan,default"
        "actsellistbox=black,cyan"
      ]
    );
  };
}
