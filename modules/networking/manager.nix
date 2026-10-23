{ config, lib, ... }:
{
  flake.modules.nixos.pc = {
    networking.networkmanager.enable = true;
    users.users.${config.flake.meta.owner.username}.extraGroups = [ "networkmanager" ];
  };

  # nmtui (and other newt programs, like whiptail) in the terminal's own
  # colours. newt's defaults assume a VGA palette (light "lightgray" windows on
  # deep blue), which a Noctalia palette turns into pastel on pastel, about
  # 1.2:1. "default" is the terminal's foreground/background; cyan is the
  # accent with the most contrast in both Tokyo Night modes.
  flake.modules.homeManager.gui.home.sessionVariables.NEWT_COLORS = lib.mkDefault (
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
}
