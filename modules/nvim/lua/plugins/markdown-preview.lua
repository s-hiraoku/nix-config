-- Markdown プレビュー（ブラウザでライブ表示・スクロール同期）
-- 既存の render-markdown.nvim は nvim 内レンダリング、こちらはブラウザ表示で用途が異なる。
-- プレビューサーバは Node.js を利用する（このマシンでは volta の node v24 が PATH 上にある）。
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  -- yarn ビルドを避け、install.sh でプラットフォーム別のビルド済みバイナリをDLする。
  -- mkdp#util#install() は lazy 初回インストール時に確実に走らないことがあるため、
  -- install.sh を直接叩いて bin/ を必ず生成させる。
  build = "cd app && bash install.sh",
  init = function()
    -- ファイルタイプは markdown のみを対象にする
    vim.g.mkdp_filetypes = { "markdown" }
    -- カーソル位置に合わせてプレビューを自動スクロール
    vim.g.mkdp_auto_close = 1
  end,
  keys = {
    {
      "<leader>mv",
      "<cmd>MarkdownPreviewToggle<cr>",
      desc = "Markdown: toggle browser preview",
      ft = "markdown",
    },
  },
}
