-- Markdown レンダリング（nvim 内でリッチ表示）
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  opts = {
    -- 見出しの記号をアイコンに置き換えて色付け
    heading = { enabled = true },
    -- コードブロックを背景色付きで表示
    code = { enabled = true, style = "full" },
    -- チェックボックスを ✅ / ☐ に置き換え
    checkbox = { enabled = true },
    -- 表のボーダーを綺麗に描画
    pipe_table = { enabled = true },
  },
  keys = {
    {
      "<leader>mp",
      function()
        local state = require("render-markdown.state")
        if state.enabled then
          require("render-markdown").disable()
        else
          require("render-markdown").enable()
        end
      end,
      desc = "Markdown: toggle render",
      ft = "markdown",
    },
  },
}
