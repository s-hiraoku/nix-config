-- lazygit を nvim 内のフローティングウィンドウで開く
-- 本体 (lazygit バイナリ) は Nix で導入済み (modules/lazygit.nix)。
-- 設定 (delta ページャ / <C-g> の AI コミット等) もそちらで管理している。
return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Git: LazyGit (project root)" },
    { "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", desc = "Git: LazyGit (current file repo)" },
  },
}
