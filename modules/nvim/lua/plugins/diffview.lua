-- diffview.nvim — コミット差分の閲覧
-- gitsigns blame (<leader>hb) で見たコミットを起点に、blame 行のコミットの
--   <leader>hD : コミット全体の変更ファイル一覧 + 各差分（panels-old-new の 3 ペイン）
-- を開く。実体のキーマップ／ロジックは gitsigns の on_attach (plugins/ui.lua) と
-- config/git-blame-actions.lua 側にある。ここでは cmd 起動で遅延ロードするだけ。
-- （<leader>hd の単一ファイル差分は diffview ではなく git show の簡素ビュー）
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  opts = {
    -- q は素の close（1 ウィンドウずつ）ではなく diffview 全体を一発で閉じる。
    -- file パネル / diff ビュー / ファイル履歴パネルのどこからでも効くようにする。
    keymaps = {
      view = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Diffview を閉じる" } } },
      file_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Diffview を閉じる" } } },
      file_history_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Diffview を閉じる" } } },
    },
  },
}
