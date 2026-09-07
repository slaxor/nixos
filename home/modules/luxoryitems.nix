# this is currently just a bag of dogfood I don't yet know what to do with
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    graphviz-nox
    imagemagick
    libqalculate
    lilypond
    mermaid-cli
    miller # data manipulation for csv,json etc.
    nh
    qrencode
    rtl-sdr
    dump1090-fa
    soapysdr-with-plugins
    signal-cli
    tinymist
    typst
    udiskie
    toot
    tut
    stu
    s3fs
    s3proxy
  ];
}
