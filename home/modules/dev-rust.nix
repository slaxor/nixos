{
  pkgs,
  ...
}:
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
