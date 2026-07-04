-- コード内の TODO / FIXME / HACK / NOTE などをハイライト・一覧表示
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    signs = true,
    highlight = {
      before = "",
      keyword = "wide",
      after = "fg",
    },
    keywords = {
      FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
    },
  },
  keys = {
    { "<leader>tl", "<cmd>TodoTelescope<CR>", desc = "TODO: list (Telescope)" },
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "TODO: next",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "TODO: previous",
    },
  },
}
