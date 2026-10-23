{ lib, ... }:
{
  flake.modules.homeManager.gui =
    hmArgs@{ pkgs, ... }:
    let
      noctalia = lib.getExe hmArgs.config.programs.noctalia.package;
    in
    {
      home.sessionVariables.BROWSER = lib.getExe hmArgs.config.programs.firefox.package;

      programs = {
        firefox = {
          configPath = "${hmArgs.config.xdg.configHome}/mozilla/firefox";
          enable = true;
          profiles = {
            primary = {
              id = 0;
              settings = {
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                "browser.ctrlTab.sortByRecentlyUsed" = true;
                "browser.tabs.closeWindowWithLastTab" = false;
              };
              userChrome = ''
                #TabsToolbar {
                  visibility: collapse !important;
                  margin-bottom: 21px !important;
                }
              '';
              userContent = "";
            };
          };

          # Noctalia colours through the Pywalfox extension (added in Firefox),
          # with Noctalia as its native messaging host. The manifest lives in
          # ~/.mozilla even with XDG profiles.
          nativeMessagingHosts = [
            (pkgs.writeTextDir "lib/mozilla/native-messaging-hosts/pywalfox.json" (
              builtins.toJSON {
                name = "pywalfox";
                description = "Noctalia Firefox theme native messaging host";
                path = noctalia;
                type = "stdio";
                allowed_extensions = [ "pywalfox@frewacom.org" ];
              }
            ))
          ];
        };

        # Its community pywalfox template, vendored in firefox-noctalia/
        # (noctalia-dev/community-templates@a38fc33, pywalfox/). The template's
        # firefox-theme post_action is replaced by its two CLI steps (mode,
        # update): it would also rewrite the manifest to Noctalia's unwrapped
        # binary.
        noctalia.settings.theme.templates.user.pywalfox = {
          input_path = lib.mkDefault "${./firefox-noctalia/pywalfox.json}";
          output_path = lib.mkDefault "$XDG_CACHE_HOME/wal/colors.json";
          post_hook = lib.mkDefault "${noctalia} firefox-theme {{ mode }}; ${noctalia} firefox-theme update || true";
        };
      };

      wayland.windowManager.hyprland.extraConfig = ''
        bind(mod .. " + W", app("${lib.getExe hmArgs.config.programs.firefox.package}"), "Browser")
      '';

      xdg.mimeApps.defaultApplications =
        [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/chrome"
          "x-scheme-handler/file"
          "text/html"
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/xhtml+xml"
          "application/x-extension-xhtml"
          "application/x-extension-xht"
        ]
        |> map (type: lib.nameValuePair type [ "firefox.desktop" ])
        |> lib.listToAttrs;
    };
}
