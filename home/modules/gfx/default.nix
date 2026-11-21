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
    defaultFor = [ "application/pdf" ];
  };

  programs.vectorcraft = {
    enable = true;
    defaultFor = [
      "image/svg+xml"
      "application/x-vectorcraft"
    ];
  };

  programs.solidcraft.enable = true;
  programs.fieldcraft.enable = true;
  programs.photocraft.enable = true;
  programs.lightcraft.enable = true;
  programs.soundcraft.enable = true;
  # programs.designcraft.enable = true;
  programs.figcraft.enable = true;
  # programs.filmcraft.enable = true;
  # programs.deckcraft.enable = true;
  programs.cadcraft.enable = true;
  # programs.effectcraft.enable = true;
  # programs.gridcraft.enable = true;
  # programs.materialcraft.enable = true;
  # programs.texturecraft.enable = true;
  # programs.wordcraft.enable = true;
}
