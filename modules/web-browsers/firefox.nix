{ lib, ... }:
{
  flake.modules.homeManager.gui = hmArgs: {
    programs.firefox = {
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
    };

    stylix.targets.firefox.profileNames = [ "primary" ];

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
