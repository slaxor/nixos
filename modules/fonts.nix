{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pango
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.iosevka
      nerd-fonts.go-mono
      liberation_ttf
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];
  };
}

