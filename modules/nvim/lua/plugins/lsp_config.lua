-- LSP (Language Server Protocol) の設定
-- nvim 0.11+ の vim.lsp.config / vim.lsp.enable API を使用
--
-- 実装は責務ごとに lua/lsp/ 配下へ分離している:
--   lsp.servers — Mason / サーバー別設定 / eslint 保存時 fixAll
--   lsp.keymaps — LspAttach 時のバッファローカルキーマップ
--   lsp.ui      — ホバー/シグネチャのフロート装飾・診断アイコン
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    require("lsp.servers").setup()
    require("lsp.keymaps").setup()
    require("lsp.ui").setup()
  end,
}
