{ pkgs, ... }:
let
  name = "Sascha Teske";
  secret = account: "gopass show -o mail/${account}";
  # secret = account: "secret-tool lookup service mail account ${account}";
  sync = {
    enable = true;
    create = "both";
    expunge = "both";
  };
in
{
  home.packages = [ pkgs.libsecret ];

  accounts.email = {
    maildirBasePath = "mail";
    accounts = {
      microprojects = {
        primary = true;
        address = "sascha.teske@microprojects.de";
        userName = "sascha.teske@microprojects.de";
        realName = name;
        imap.host = "mail.microprojects.de";
        smtp = {
          host = "mail.microprojects.de";
          port = 465;
        };
        passwordCommand = secret "microprojects";
        mbsync = sync;
        msmtp.enable = true;
        neomutt.enable = true;
      };
      accounting = {
        address = "accounting@microprojects.de";
        userName = "accounting@microprojects.de";
        realName = name;
        imap.host = "mail.microprojects.de";
        smtp = {
          host = "mail.microprojects.de";
          port = 465;
        };
        passwordCommand = secret "accounting";
        mbsync = sync;
        msmtp.enable = true;
        neomutt.enable = true;
      };
      gmail = {
        address = "sascha.teske@gmail.com";
        userName = "sascha.teske@gmail.com";
        realName = name;
        flavor = "gmail.com";
        smtp.port = 465;
        passwordCommand = secret "gmail";
        mbsync = sync // {
          patterns = [
            "*"
            "![Gmail]*"
            "[Gmail]/Sent Mail"
            "[Gmail]/Drafts"
            "[Gmail]/Trash"
          ];
        };
        msmtp.enable = true;
        neomutt.enable = true;
      };
      posteo = {
        address = "slaxor@posteo.de";
        userName = "slaxor@posteo.de";
        realName = name;
        imap.host = "posteo.de";
        smtp = {
          host = "posteo.de";
          port = 465;
        };
        passwordCommand = secret "posteo";
        mbsync = sync;
        msmtp.enable = true;
        neomutt.enable = true;
      };
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  programs.neomutt = {
    enable = true;
    vimKeys = true;
    sort = "reverse-threads";
    sidebar = {
      enable = true;
      width = 28;
      shortPath = true;
    };
    extraConfig = ''
      set mail_check_stats
      set sidebar_folder_indent
      bind index,pager \Ck sidebar-prev
      bind index,pager \Cj sidebar-next
      bind index,pager \Co sidebar-open
    '';
  };

  services.mbsync = {
    enable = true;
    frequency = "*:0/5";
  };
}

# { pkgs, ... }:
# {
# home.packages = with pkgs; [
# aspell
# aspellDicts.de
# aspellDicts.en
# gnupg
# gnutls
# isync # for mbsync
# khal
# khard
# mutt
# notmuch
# tmux
# unzip
# ];
#
# programs = {
# mbsync.enable = true;
# };
# }
