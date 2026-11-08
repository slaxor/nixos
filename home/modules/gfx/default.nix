{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gimp
    simple-scan
    sane-backends
    naps2
  ];
  programs.pdfcraft = {
    enable = true;
    defaultPdfHandler = true;
  };
}
