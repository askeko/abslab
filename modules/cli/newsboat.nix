{ lib, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.newsboat = {
        enable = true;
        autoReload = lib.mkDefault true;
        urls = [
          {
            url = "https://www.archlinux.org/feeds/news/";
            tags = [ "tech" ];
          }
          {
            url = "https://www.dr.dk/nyheder/service/feeds/senestenyt";
            tags = [ "news" ];
          }
          {
            url = "https://hnrss.org/frontpage";
            tags = [ "news" ];
          }
        ];
        extraConfig = ''
          external-url-viewer "${lib.getExe pkgs.urlscan} -dc -r 'xdg-open {}'"

          bind-key j down
          bind-key k up
          bind-key j next articlelist
          bind-key k prev articlelist
          bind-key J next-feed articlelist
          bind-key K prev-feed articlelist
          bind-key G end
          bind-key g home
          bind-key d pagedown
          bind-key u pageup
          bind-key o open
          bind-key h quit
          bind-key a toggle-article-read
          bind-key n next-unread
          bind-key N prev-unread
          bind-key D pb-download
          bind-key U show-urls
          bind-key x pb-delete
        '';
      };
    };
}
