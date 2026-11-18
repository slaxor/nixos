{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pango
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      dina-font
      liberation_ttf
      mplus-outline-fonts.githubRelease
      nerd-font-patcher
      nerd-fonts.droid-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.go-mono
      nerd-fonts.iosevka
      nerd-fonts.symbols-only
      proggyfonts
      texlivePackages.universalis
    ];
  };
}
