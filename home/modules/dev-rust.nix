{
  pkgs,
  ...
}:
let
  mdbook-plugins = pkgs.mdbook-plugins.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.libgit2
      pkgs.sqlite
    ];
  });
in
{
  home.packages = with pkgs; [
    # rust
    rustup
    probe-rs-tools
    elf2uf2-rs
    mdbook
    mdbook-pdf
    mdbook-epub
    mdbook-plugins
    # cargo-bootimage
    # cargo
    # rust-script
    # rust-analyzer
  ];
}
