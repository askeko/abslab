{ inputs, lib, ... }:
let
  # Rosé Pine's Firefox port in its userChrome form: a restyle of the browser
  # (userChrome.css) and of its own pages (userContent.css, which imports
  # userColors.css), with the arrow icons it uses, all from its dist/ into the
  # profile's chrome/.
  port = "${inputs.rose-pine-firefox}/dist";
in
{
  flake.modules.homeManager.gui = hmArgs: {
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
            userChrome = builtins.readFile "${port}/userChrome.css" + ''

              #TabsToolbar {
                visibility: collapse !important;
                margin-bottom: 21px !important;
              }
            '';
            userContent = builtins.readFile "${port}/userContent.css";
          };
        };
      };
    };

    home.file =
      lib.genAttrs'
        [
          "userColors.css"
          "add.svg"
          "left-arrow.svg"
          "right-arrow.svg"
        ]
        (
          file:
          lib.nameValuePair "${hmArgs.config.programs.firefox.profilesPath}/primary/chrome/${file}" {
            source = "${port}/${file}";
          }
        );

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
