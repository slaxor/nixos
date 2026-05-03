{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixdoc
    nixfmt-rfc-style
  ];

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
