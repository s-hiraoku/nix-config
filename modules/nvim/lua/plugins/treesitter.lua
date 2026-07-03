-- シンタックスハイライト・構文解析
-- nvim-treesitter v1.0+ では require("nvim-treesitter").setup() を使用
-- highlight/indent は Neovim 組み込みの vim.treesitter が自動で処理する
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  main = "nvim-treesitter",
  opts = {
    ensure_installed = {
      "typescript",
      "javascript",
      "tsx",
      "python",
      "lua",
      "json",
      "jsonc",
      "yaml",
      "html",
      "css",
      "markdown",
      "markdown_inline",
      "bash",
      "gitignore",
    },
    auto_install = true,
    -- vim-matchup と treesitter を連携（括弧・タグのハイライト精度向上）
    matchup = { enable = true },
  },
}
