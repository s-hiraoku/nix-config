-- インデントガイド（indent-rainbow 相当）
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- neo-tree のディレクトリ線くらい細い見た目にする
    --   "▏"(U+258F) は "│" より細いグリフ
    indent = { char = "▏" },
    scope = { enabled = true, char = "▏" },
    exclude = {
      filetypes = { "help", "neo-tree", "lazy", "mason" },
    },
  },
}
