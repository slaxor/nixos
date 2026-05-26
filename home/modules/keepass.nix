{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    keepassxc
    keepassxc-go
  ];
  programs.keepassxc = {
    enable = true;
    autostart = true;
    settings = {
      General = {
        AutoGeneratePasswordForNewEntries = true;
        BackupBeforeSave = true;
        HideWindowOnCopy = false;
        MinimizeAfterUnlock = false;
        MinimizeOnOpenUrl = false;
      };
      Browser = {
        Enabled = true;
        Browser_AllowLocalhostWithPasskeys = true;
        SearchInAllDatabases = true;
      };
      GUI = {
        MinimizeOnStartup = true;
        TrayIconAppearance = "monochrome-light";
        ColorPasswords = true;
        MinimizeOnClose = true;
        MinimizeToTray = true;
        MonospaceNotes = true;
        MovableToolbar = false;
        ShowTrayIcon = true;
        ToolButtonStyle = 0;
      };
      FdoSecrets.Enabled = true;
      SSHAgent.Enabled = true;
      Security = {
        ClearClipboardTimeout = 30;
        ClearSearch = true;
        EnableCopyOnDoubleClick = true;
        HideTotpPreviewPanel = false;
        IconDownloadFallback = true;
        LockDatabaseIdleSeconds = 7200;
        PasswordEmptyPlaceholder = true;
        Security_HideNotes = true;
      };
      PasswordGenerator = {
        Length = 17;
        AdvancedMode = true;
        Logograms = true;
        UpperCase = true;
        WordCount = 15;
        # AdditionalChars=;
        # ExcludedChars=;
      };
      KeeShare = {
        Active = "<?xml version=\"1.0\"?><KeeShare><Active><Import/><Export/></Active></KeeShare>\n";
        QuietSuccess = true;
      };
    };
  };

  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC Secret Service";
      After = [
        "graphical-session.target"
        "dbus.service"
      ];
    };
    Service = {
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc --minimized --keyfile ${config.xdg.dataHome}/keepasxc/$USERs-passwords.key ${config.xdg.dataHome}/keepasxc/$USERs-passwords.kdbx";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
