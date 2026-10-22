{ lib, ... }:
{
  # Noctalia colours: its community zathura template, vendored in
  # zathura-noctalia/ (noctalia-dev/community-templates@0f898db, zathura/),
  # included from zathurarc. Its apply.sh only reloads open windows over D-Bus;
  # the post_hook does the same.
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      programs.zathura = {
        enable = true;
        extraConfig = "include noctaliarc";
      };
      xdg.mimeApps.defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };

      programs.noctalia.settings.theme.templates.user.zathura = {
        input_path = lib.mkDefault "${./zathura-noctalia/zathurarc}";
        output_path = lib.mkDefault "$XDG_CONFIG_HOME/zathura/noctaliarc";
        post_hook = lib.mkDefault (
          lib.getExe (
            pkgs.writeShellApplication {
              name = "zathura-reload";
              runtimeInputs = [ pkgs.dbus ];
              text = ''
                for id in $(dbus-send --session --print-reply --dest=org.freedesktop.DBus \
                  /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep -o 'org.pwmt.zathura.PID-[0-9]*' || true); do
                  dbus-send --session --dest="$id" /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:source
                done
              '';
            }
          )
        );
      };
    };
}
