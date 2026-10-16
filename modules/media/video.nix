{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ vlc ];

      xdg.mimeApps.defaultApplications = lib.genAttrs [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/vnd.avi"
        "video/mpeg"
        "video/ogg"
        "video/x-flv"
        "video/3gpp"
        "audio/mpeg"
        "audio/flac"
        "audio/ogg"
        "audio/x-vorbis+ogg"
        "audio/x-opus+ogg"
        "audio/vnd.wave"
        "audio/mp4"
        "audio/aac"
      ] (_: [ "vlc.desktop" ]);
    };
}
