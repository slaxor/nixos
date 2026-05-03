{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixdoc
    nixfmt-rfc-style
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 8";
    flake = "${config.home.homeDirectory}/git/codeberg.org/slaxor/home-manager";
  };

  programs.neovim = {
    extraLuaConfig = /* lua */ ''
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.nix",
        callback = function() vim.lsp.buf.format() end,
      })
    '';
  };
  # home.shellAliases = {
  # };
}
