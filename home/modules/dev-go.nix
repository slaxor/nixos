{
  config,
  pkgs,
  ...
}:
let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    plugins: with plugins; [
      go
      gomod
      gosum
      gowork
      sql
      gotmpl
      json
      comment
    ]
  );
in
{
  home.packages = with pkgs; [
    bruno
    delve
    ginkgo
    go
    gofumpt
    golangci-lint
    golangci-lint-langserver
    golines
    gomodifytags
    gopls
    gotestsum
    govulncheck
    grpcurl
    iferr
    mockgen
    richgo
  ];

  home.file.".local/share/applications/bruno.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Name=Bruno
    Comment=Bruno File Manager
    Exec=bruno
    Icon=bruno
    Terminal=false
    Type=Application
    Categories=Utility;Development;
    StartupWMClass=bruno
  '';

  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN = "${config.home.homeDirectory}/go/bin";
    PATH = "${config.home.homeDirectory}/go/bin:${pkgs.go}/bin:$PATH";
  };

  # home.activation.installGoTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  # echo "Installing Go tools..."
  # ${pkgs.go}/bin/go install github.com/abenz1267/gomvp@latest
  # ${pkgs.go}/bin/go install github.com/abice/go-enum@latest
  # ${pkgs.go}/bin/go install github.com/cweill/gotests/...@latest
  # ${pkgs.go}/bin/go install github.com/davidrjenni/reftools/cmd/fillswitch@latest
  # ${pkgs.go}/bin/go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
  # ${pkgs.go}/bin/go install github.com/josharian/impl@latest
  # ${pkgs.go}/bin/go install github.com/tmc/json-to-struct@latest
  # ${pkgs.go}/bin/go install github.com/twpayne/go-jsonstruct/v3/cmd/gojsonstruct@latest
  # ${pkgs.go}/bin/go install golang.org/x/tools/cmd/callgraph@latest
  # ${pkgs.go}/bin/go install golang.org/x/tools/cmd/goimports@latest
  # ${pkgs.go}/bin/go install golang.org/x/tools/cmd/gonew@latest
  # '';
}
