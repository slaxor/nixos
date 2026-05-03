{ pkgs, config, ... }:
# let
  # nvim-spell-de-utf8-dictionary = builtins.fetchurl {
    # url = "https://ftp.pl.vim.org/pub/vim/runtime/spell/de.utf-8.spl";
    # sha256 = "sha256:1ld3hgv1kpdrl4fjc1wwxgk4v74k8lmbkpi1x7dnr19rldz11ivk";
  # };
# in
{
  home.packages = with pkgs; [
		claude-code
  ];

  # programs.neovim = {
    # "efm-langserver/config.yaml".source = ./efm-langserver/config.yaml;
  # };
}

